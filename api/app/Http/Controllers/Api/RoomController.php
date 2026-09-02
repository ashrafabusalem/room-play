<?php

namespace App\Http\Controllers\Api;

use App\Events\RoomMessageSent;
use App\Events\RoomStateChanged;
use App\Http\Controllers\Controller;
use App\Http\Resources\RoomMessageResource;
use App\Http\Resources\RoomResource;
use App\Models\Room;
use App\Models\RoomBan;
use App\Models\RoomMember;
use App\Models\RoomMessage;
use App\Models\RoomSeat;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class RoomController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        $rooms = Room::whereNull('closed_at')->with(['host', 'members.user', 'seats.user'])
            ->orderByDesc('is_featured')->latest()->paginate(30);

        return RoomResource::collection($rooms);
    }

    public function show(Room $room): RoomResource
    {
        abort_if($room->closed_at, 404);

        return new RoomResource($room);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'min:2', 'max:80'],
            'language' => ['required', Rule::in(['EN', 'AR'])],
            'tag' => ['sometimes', Rule::in(['chatting', 'gaming', 'music', 'party'])],
        ]);

        if (Room::where('host_user_id', $request->user()->id)->whereNull('closed_at')->exists()) {
            throw ValidationException::withMessages(['name' => 'You already host an active room.']);
        }

        $room = DB::transaction(function () use ($data, $request) {
            $room = Room::create([...$data, 'host_user_id' => $request->user()->id]);
            RoomMember::create(['room_id' => $room->id, 'user_id' => $request->user()->id, 'role' => 'host']);
            foreach (range(1, $room->seat_count) as $position) {
                RoomSeat::create(['room_id' => $room->id, 'position' => $position, 'user_id' => $position === 1 ? $request->user()->id : null]);
            }

            return $room;
        });

        return response()->json(['room' => (new RoomResource($room))->resolve()], 201);
    }

    public function join(Request $request, Room $room): JsonResponse
    {
        $this->assertOpen($room);
        abort_if(RoomBan::where(['room_id' => $room->id, 'user_id' => $request->user()->id])->exists(), 403, 'You are banned from this room.');
        DB::transaction(function () use ($request, $room) {
            $locked = Room::lockForUpdate()->findOrFail($room->id);
            abort_if($locked->is_locked, 403, 'This room is locked.');
            $count = RoomMember::where('room_id', $room->id)->count();
            abort_if($count >= $locked->max_members, 409, 'This room is full.');
            RoomMember::updateOrCreate(['room_id' => $room->id, 'user_id' => $request->user()->id], ['last_seen_at' => now()]);
        });

        return $this->state($room, true);
    }

    public function leave(Request $request, Room $room): JsonResponse
    {
        abort_if($room->host_user_id === $request->user()->id, 409, 'The host must close the room.');
        DB::transaction(function () use ($request, $room) {
            RoomSeat::where('room_id', $room->id)->where('user_id', $request->user()->id)->update(['user_id' => null, 'mic_muted' => true]);
            RoomMember::where('room_id', $room->id)->where('user_id', $request->user()->id)->delete();
        });

        return $this->state($room, true);
    }

    public function takeSeat(Request $request, Room $room, int $position): JsonResponse
    {
        $this->assertMember($request, $room);
        abort_unless($position >= 1 && $position <= $room->seat_count, 404);

        try {
            DB::transaction(function () use ($request, $room, $position) {
                $seat = RoomSeat::where('room_id', $room->id)->where('position', $position)->lockForUpdate()->firstOrFail();
                abort_if($seat->is_locked, 403, 'This seat is locked.');
                abort_if($seat->user_id && $seat->user_id !== $request->user()->id, 409, 'This seat is already occupied.');
                RoomSeat::where('room_id', $room->id)->where('user_id', $request->user()->id)->whereKeyNot($seat->id)->update(['user_id' => null, 'mic_muted' => true]);
                $seat->update(['user_id' => $request->user()->id, 'mic_muted' => true]);
            });
        } catch (QueryException) {
            abort(409, 'This seat changed. Try again.');
        }

        return $this->state($room, true);
    }

    public function leaveSeat(Request $request, Room $room): JsonResponse
    {
        abort_if($room->host_user_id === $request->user()->id, 409, 'The host must remain seated.');
        RoomSeat::where('room_id', $room->id)->where('user_id', $request->user()->id)->update(['user_id' => null, 'mic_muted' => true]);

        return $this->state($room, true);
    }

    public function microphone(Request $request, Room $room): JsonResponse
    {
        $data = $request->validate(['muted' => ['required', 'boolean']]);
        $updated = RoomSeat::where('room_id', $room->id)->where('user_id', $request->user()->id)->update(['mic_muted' => $data['muted']]);
        abort_unless($updated, 409, 'Take a seat before using the microphone.');

        return $this->state($room, true);
    }

    public function lockSeat(Request $request, Room $room, int $position): JsonResponse
    {
        $this->assertHost($request, $room);
        $data = $request->validate(['locked' => ['required', 'boolean']]);
        $seat = RoomSeat::where('room_id', $room->id)->where('position', $position)->firstOrFail();
        abort_if($data['locked'] && $seat->user_id, 409, 'Remove the occupant before locking this seat.');
        $seat->update(['is_locked' => $data['locked']]);

        return $this->state($room, true);
    }

    public function removeMember(Request $request, Room $room, User $user): JsonResponse
    {
        $this->assertHost($request, $room);
        abort_if($user->id === $room->host_user_id, 422, 'The host cannot be removed.');
        abort_unless(RoomMember::where(['room_id' => $room->id, 'user_id' => $user->id])->exists(), 404);
        DB::transaction(function () use ($room, $user) {
            RoomSeat::where(['room_id' => $room->id, 'user_id' => $user->id])->update(['user_id' => null, 'mic_muted' => true]);
            RoomMember::where(['room_id' => $room->id, 'user_id' => $user->id])->delete();
        });

        return $this->state($room, true);
    }

    public function banMember(Request $request, Room $room, User $user): JsonResponse
    {
        $this->assertHost($request, $room);
        abort_if($user->id === $room->host_user_id, 422, 'The host cannot be banned.');
        DB::transaction(function () use ($request, $room, $user) {
            RoomBan::updateOrCreate(['room_id' => $room->id, 'user_id' => $user->id], ['banned_by' => $request->user()->id]);
            RoomSeat::where(['room_id' => $room->id, 'user_id' => $user->id])->update(['user_id' => null, 'mic_muted' => true]);
            RoomMember::where(['room_id' => $room->id, 'user_id' => $user->id])->delete();
        });

        return $this->state($room, true);
    }

    public function bans(Request $request, Room $room): JsonResponse
    {
        $this->assertHost($request, $room);

        return response()->json(['users' => RoomBan::where('room_id', $room->id)->with('user')->latest()->get()->map(fn ($ban) => ['id' => $ban->user->public_id, 'name' => $ban->user->name, 'avatar_url' => $ban->user->avatarUrl()])->values()]);
    }

    public function unban(Request $request, Room $room, User $user): JsonResponse
    {
        $this->assertHost($request, $room);
        RoomBan::where(['room_id' => $room->id, 'user_id' => $user->id])->delete();

        return response()->json(['message' => 'Room ban removed.']);
    }

    public function updateSettings(Request $request, Room $room): JsonResponse
    {
        $this->assertHost($request, $room);
        $data = $request->validate([
            'name' => ['required', 'string', 'min:2', 'max:80'],
            'language' => ['required', Rule::in(['EN', 'AR'])],
            'tag' => ['required', Rule::in(['chatting', 'gaming', 'music', 'party'])],
            'is_locked' => ['required', 'boolean'],
        ]);
        $room->update($data);

        return $this->state($room, true);
    }

    public function close(Request $request, Room $room): JsonResponse
    {
        $this->assertHost($request, $room);
        $room->update(['closed_at' => now()]);

        return $this->state($room, true);
    }

    public function messages(Request $request, Room $room): JsonResponse
    {
        $this->assertMember($request, $room);
        $messages = RoomMessage::where('room_id', $room->id)->with(['user', 'room'])
            ->latest('id')->limit(100)->get()->reverse()->values();

        return response()->json(['messages' => RoomMessageResource::collection($messages)->resolve()]);
    }

    public function sendMessage(Request $request, Room $room): JsonResponse
    {
        $this->assertMember($request, $room);
        $data = $request->validate(['text' => ['required', 'string', 'max:500']]);
        $message = RoomMessage::create([
            'room_id' => $room->id,
            'user_id' => $request->user()->id,
            'body' => trim($data['text']),
        ])->load(['user', 'room']);
        broadcast(new RoomMessageSent($message))->toOthers();

        return response()->json(['message' => (new RoomMessageResource($message))->resolve()], 201);
    }

    private function assertOpen(Room $room): void
    {
        abort_if($room->closed_at, 404);
    }

    private function assertMember(Request $request, Room $room): void
    {
        $this->assertOpen($room);
        abort_unless(RoomMember::where('room_id', $room->id)->where('user_id', $request->user()->id)->exists(), 403, 'Join the room first.');
    }

    private function assertHost(Request $request, Room $room): void
    {
        $this->assertOpen($room);
        abort_unless($room->host_user_id === $request->user()->id, 403, 'Only the room host can do that.');
    }

    private function state(Room $room, bool $broadcast = false): JsonResponse
    {
        if ($broadcast) {
            $room->increment('state_version');
        }
        $room = $room->fresh(['host', 'members.user', 'seats.user']);
        if ($broadcast) {
            broadcast(new RoomStateChanged($room))->toOthers();
        }

        return response()->json(['room' => (new RoomResource($room))->resolve()]);
    }
}
