<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GameRequest;
use App\Models\GameSession;
use App\Models\Room;
use App\Models\RoomMember;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class GameRequestController extends Controller
{
    public function store(Request $request, Room $room): JsonResponse
    {
        $this->member($request, $room);
        abort_if($room->host_user_id === $request->user()->id, 422, 'The host can start a game directly.');
        $data = $request->validate(['game' => ['required', Rule::in(['spy', 'truth_or_dare'])]]);
        $gameRequest = GameRequest::firstOrCreate([
            'room_id' => $room->id,
            'requester_id' => $request->user()->id,
            'game' => $data['game'],
            'status' => 'pending',
        ]);

        return response()->json(['request' => $this->payload($gameRequest->load('requester'))], 201);
    }

    public function pending(Request $request, Room $room): JsonResponse
    {
        $this->host($request, $room);
        $item = GameRequest::where(['room_id' => $room->id, 'status' => 'pending'])
            ->with('requester')->oldest()->first();

        return response()->json(['request' => $item ? $this->payload($item) : null]);
    }

    public function respond(Request $request, GameRequest $gameRequest): JsonResponse
    {
        $this->host($request, $gameRequest->room);
        abort_unless($gameRequest->status === 'pending', 409, 'This request was already answered.');
        $data = $request->validate(['action' => ['required', Rule::in(['accept', 'decline'])]]);
        $accepted = $data['action'] === 'accept';
        $gameRequest->update(['status' => $accepted ? 'accepted' : 'declined', 'responded_at' => now()]);
        if ($accepted) {
            GameSession::firstOrCreate(
                ['room_id' => $gameRequest->room_id, 'game' => $gameRequest->game, 'status' => 'lobby'],
                ['host_user_id' => $gameRequest->room->host_user_id],
            );
        }

        return response()->json(['request' => $this->payload($gameRequest->load('requester'))]);
    }

    private function payload(GameRequest $request): array
    {
        return [
            'id' => $request->id,
            'game' => $request->game,
            'status' => $request->status,
            'requester' => ['id' => $request->requester->public_id, 'name' => $request->requester->name],
        ];
    }

    private function member(Request $request, Room $room): void
    {
        abort_unless(RoomMember::where(['room_id' => $room->id, 'user_id' => $request->user()->id])->exists(), 403);
    }

    private function host(Request $request, Room $room): void
    {
        $this->member($request, $room);
        abort_unless($room->host_user_id === $request->user()->id, 403);
    }
}
