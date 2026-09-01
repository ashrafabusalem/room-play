<?php

namespace App\Http\Controllers\Api;

use App\Events\GameSessionChanged;
use App\Http\Controllers\Controller;
use App\Models\GamePrompt;
use App\Models\GameSession;
use App\Models\GameSessionPlayer;
use App\Models\Room;
use App\Models\RoomMember;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SpyGameController extends Controller
{
    public function show(Request $request, Room $room): JsonResponse
    {
        $this->member($request, $room);
        $session = GameSession::where('room_id', $room->id)
            ->where('game', 'spy')->whereIn('status', ['lobby', 'active', 'revealed'])
            ->latest()->first();

        return response()->json(['session' => $session ? $this->state($request, $session) : null]);
    }

    public function store(Request $request, Room $room): JsonResponse
    {
        $this->member($request, $room);
        abort_unless($room->host_user_id === $request->user()->id, 403);
        $session = GameSession::firstOrCreate(
            ['room_id' => $room->id, 'game' => 'spy', 'status' => 'lobby'],
            ['host_user_id' => $request->user()->id],
        );

        return response()->json(['session' => $this->state($request, $session)], 201);
    }

    public function start(Request $request, GameSession $session): JsonResponse
    {
        $this->host($request, $session);
        abort_unless($session->game === 'spy' && $session->status === 'lobby', 409);
        $userIds = $session->room->seats()->whereNotNull('user_id')->orderBy('position')->pluck('user_id')->unique()->values();
        abort_if($userIds->count() < 3, 422, 'At least three seated players are required.');
        $word = GamePrompt::where(['game' => 'spy', 'type' => 'word', 'is_active' => true])->inRandomOrder()->firstOrFail();
        $spyId = $userIds->random();

        DB::transaction(function () use ($session, $userIds, $word, $spyId) {
            $session->players()->delete();
            foreach ($userIds->shuffle()->values() as $index => $userId) {
                GameSessionPlayer::create(['game_session_id' => $session->id, 'user_id' => $userId, 'position' => $index + 1]);
            }
            $session->update(['status' => 'active', 'current_player_id' => $spyId, 'current_prompt_id' => $word->id, 'turn_number' => 1, 'started_at' => now()]);
        });
        $this->broadcast($session);

        return response()->json(['session' => $this->state($request, $session->refresh())]);
    }

    public function reveal(Request $request, GameSession $session): JsonResponse
    {
        $this->host($request, $session);
        abort_unless($session->game === 'spy' && $session->status === 'active', 409);
        $session->update(['status' => 'revealed', 'finished_at' => now()]);
        $this->broadcast($session);

        return response()->json(['session' => $this->state($request, $session->refresh())]);
    }

    private function state(Request $request, GameSession $session): array
    {
        $session->load(['players.user', 'currentPlayer', 'currentPrompt', 'room']);
        $isSpy = $session->current_player_id === $request->user()->id;
        $revealed = $session->status === 'revealed';
        $arabic = str_starts_with(strtolower((string) $request->header('Accept-Language')), 'ar');

        return [
            'id' => $session->public_id,
            'status' => $session->status,
            'is_host' => $session->host_user_id === $request->user()->id,
            'is_spy' => $session->status !== 'lobby' ? $isSpy : null,
            'word' => $session->status !== 'lobby' && (! $isSpy || $revealed)
                ? ($arabic ? $session->currentPrompt?->text_ar : $session->currentPrompt?->text_en) : null,
            'spy' => $revealed ? ['id' => $session->currentPlayer?->public_id, 'name' => $session->currentPlayer?->name] : null,
            'players' => $session->players->map(fn ($player) => [
                'id' => $player->user->public_id, 'name' => $player->user->name,
                'level' => $player->user->level, 'avatar_url' => $player->user->avatarUrl(),
            ])->values(),
        ];
    }

    private function member(Request $request, Room $room): void
    {
        abort_unless(RoomMember::where(['room_id' => $room->id, 'user_id' => $request->user()->id])->exists(), 403);
    }

    private function host(Request $request, GameSession $session): void
    {
        $this->member($request, $session->room);
        abort_unless($session->host_user_id === $request->user()->id, 403);
    }

    private function broadcast(GameSession $session): void
    {
        broadcast(new GameSessionChanged($session->load('room')))->toOthers();
    }
}
