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
use Illuminate\Validation\Rule;

class TruthOrDareController extends Controller
{
    public function show(Request $request, Room $room): JsonResponse
    {
        $this->member($request, $room);
        $session = GameSession::where('room_id', $room->id)->where('game', 'truth_or_dare')->whereIn('status', ['lobby','active'])->latest()->first();
        return response()->json(['session' => $session ? $this->state($request, $session) : null]);
    }

    public function store(Request $request, Room $room): JsonResponse
    {
        $this->member($request, $room);
        abort_unless($room->host_user_id === $request->user()->id, 403, 'Only the room host can create a game.');
        $session = GameSession::firstOrCreate(
            ['room_id' => $room->id, 'game' => 'truth_or_dare', 'status' => 'lobby'],
            ['host_user_id' => $request->user()->id],
        );
        return response()->json(['session' => $this->state($request, $session)], 201);
    }

    public function start(Request $request, GameSession $session): JsonResponse
    {
        $this->participantRoom($request, $session);
        abort_unless($session->host_user_id === $request->user()->id && $session->status === 'lobby', 403);
        $seatUsers = $session->room->seats()->whereNotNull('user_id')->orderBy('position')->pluck('user_id')->unique()->values();
        abort_if($seatUsers->count() < 2, 422, 'At least two seated players are required.');
        DB::transaction(function () use ($session, $seatUsers) {
            $session->players()->delete();
            foreach ($seatUsers->shuffle()->values() as $index => $userId) {
                GameSessionPlayer::create(['game_session_id'=>$session->id,'user_id'=>$userId,'position'=>$index + 1]);
            }
            $session->update(['status'=>'active','current_player_id'=>$session->players()->first()->user_id,'turn_number'=>1,'started_at'=>now()]);
        });
        $this->broadcast($session);
        return response()->json(['session'=>$this->state($request,$session->refresh())]);
    }

    public function choose(Request $request, GameSession $session): JsonResponse
    {
        $this->participant($request, $session);
        abort_unless($session->status === 'active' && $session->current_player_id === $request->user()->id, 403, 'It is not your turn.');
        abort_if($session->current_prompt_id, 409, 'Complete the current prompt first.');
        $data = $request->validate(['type'=>['required',Rule::in(['truth','dare'])]]);
        $prompt = GamePrompt::where(['game'=>'truth_or_dare','type'=>$data['type'],'is_active'=>true])
            ->when($session->current_prompt_id, fn($q)=>$q->whereKeyNot($session->current_prompt_id))->inRandomOrder()->firstOrFail();
        $session->update(['current_prompt_id'=>$prompt->id]);
        $this->broadcast($session);
        return response()->json(['session'=>$this->state($request,$session->refresh())]);
    }

    public function next(Request $request, GameSession $session): JsonResponse
    {
        $this->participant($request, $session);
        abort_unless($session->status === 'active', 409);
        abort_unless($session->current_player_id === $request->user()->id || $session->host_user_id === $request->user()->id, 403);
        $players = $session->players()->get();
        $current = $players->search(fn($p)=>$p->user_id === $session->current_player_id);
        $next = $players[(($current === false ? 0 : $current + 1) % $players->count())];
        $session->update(['current_player_id'=>$next->user_id,'current_prompt_id'=>null,'turn_number'=>$session->turn_number + 1]);
        $this->broadcast($session);
        return response()->json(['session'=>$this->state($request,$session->refresh())]);
    }

    public function finish(Request $request, GameSession $session): JsonResponse
    {
        $this->participantRoom($request, $session);
        abort_unless($session->host_user_id === $request->user()->id, 403);
        $session->update(['status'=>'finished','finished_at'=>now(),'current_player_id'=>null,'current_prompt_id'=>null]);
        $this->broadcast($session);
        return response()->json(['session'=>$this->state($request,$session->refresh())]);
    }

    private function state(Request $request, GameSession $session): array
    {
        $session->load(['players.user.wallet','currentPlayer','currentPrompt','room']);
        $arabic = str_starts_with(strtolower((string)$request->header('Accept-Language')), 'ar');
        return [
            'id'=>$session->public_id,'room_id'=>$session->room->public_id,'status'=>$session->status,'turn_number'=>$session->turn_number,
            'is_host'=>$session->host_user_id===$request->user()->id,'is_my_turn'=>$session->current_player_id===$request->user()->id,
            'current_player_id'=>$session->currentPlayer?->public_id,
            'current_prompt'=>$session->currentPrompt ? ['type'=>$session->currentPrompt->type,'text'=>$arabic?$session->currentPrompt->text_ar:$session->currentPrompt->text_en] : null,
            'players'=>$session->players->map(fn($p)=>['id'=>$p->user->public_id,'name'=>$p->user->name,'level'=>$p->user->level,'avatar_url'=>$p->user->avatarUrl(),'position'=>$p->position])->values(),
        ];
    }

    private function member(Request $request, Room $room): void { abort_unless(RoomMember::where(['room_id'=>$room->id,'user_id'=>$request->user()->id])->exists(),403); }
    private function participantRoom(Request $request, GameSession $session): void { $this->member($request,$session->room); }
    private function participant(Request $request, GameSession $session): void { $this->participantRoom($request,$session); abort_unless($session->players()->where('user_id',$request->user()->id)->exists(),403); }
    private function broadcast(GameSession $session): void { broadcast(new GameSessionChanged($session->load('room')))->toOthers(); }
}
