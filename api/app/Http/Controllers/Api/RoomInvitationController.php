<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\RoomResource;
use App\Models\FriendRequest;
use App\Models\Room;
use App\Models\RoomInvitation;
use App\Models\RoomMember;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Services\InAppNotifier;

class RoomInvitationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $items = RoomInvitation::where('invitee_id', $request->user()->id)->where('status', 'pending')
            ->whereHas('room', fn ($q) => $q->whereNull('closed_at'))
            ->with(['room.host', 'room.members.user', 'room.seats.user', 'inviter'])->latest()->get();
        return response()->json(['invitations' => $items->map(fn ($invite) => [
            'id' => (string) $invite->id,
            'room' => (new RoomResource($invite->room))->resolve(),
            'inviter' => ['id' => $invite->inviter->public_id, 'name' => $invite->inviter->name, 'avatar_url' => $invite->inviter->avatarUrl()],
            'created_at' => $invite->created_at->toISOString(),
        ])->values()]);
    }

    public function store(Request $request, Room $room, User $user): JsonResponse
    {
        abort_if($room->closed_at, 404);
        abort_unless(RoomMember::where(['room_id' => $room->id, 'user_id' => $request->user()->id])->exists(), 403, 'Join the room before inviting friends.');
        abort_if($request->user()->is($user), 422, 'You are already here.');
        abort_if(RoomMember::where(['room_id' => $room->id, 'user_id' => $user->id])->exists(), 409, 'This friend is already in the room.');
        abort_unless($this->areFriends($request->user(), $user), 403, 'You can only invite friends.');
        $invite = RoomInvitation::updateOrCreate(
            ['room_id' => $room->id, 'invitee_id' => $user->id],
            ['inviter_id' => $request->user()->id, 'status' => 'pending', 'responded_at' => null],
        );
        app(InAppNotifier::class)->send($user, 'room_invitation', $request->user(), ['invitation_id'=>(string)$invite->id,'room_id'=>$room->public_id,'room_name'=>$room->name]);
        return response()->json(['invitation_id' => (string) $invite->id], 201);
    }

    public function respond(Request $request, RoomInvitation $invitation): JsonResponse
    {
        abort_unless($invitation->invitee_id === $request->user()->id && $invitation->status === 'pending', 403);
        $data = $request->validate(['accept' => ['required', 'boolean']]);
        if (! $data['accept']) {
            $invitation->update(['status' => 'declined', 'responded_at' => now()]);
            return response()->json(['message' => 'Invitation declined.']);
        }

        $room = DB::transaction(function () use ($request, $invitation) {
            $room = Room::lockForUpdate()->findOrFail($invitation->room_id);
            abort_if($room->closed_at, 404);
            abort_if($room->is_locked, 403, 'This room is locked.');
            abort_if(RoomMember::where('room_id', $room->id)->count() >= $room->max_members, 409, 'This room is full.');
            RoomMember::updateOrCreate(['room_id' => $room->id, 'user_id' => $request->user()->id], ['last_seen_at' => now()]);
            $invitation->update(['status' => 'accepted', 'responded_at' => now()]);
            return $room;
        });
        return response()->json(['room' => (new RoomResource($room))->resolve()]);
    }

    private function areFriends(User $one, User $two): bool
    {
        return FriendRequest::where('status', 'accepted')->where(fn ($q) => $q
            ->where(['requester_id' => $one->id, 'addressee_id' => $two->id])
            ->orWhere(['requester_id' => $two->id, 'addressee_id' => $one->id]))->exists();
    }
}
