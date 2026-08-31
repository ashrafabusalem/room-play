<?php

namespace App\Http\Controllers\Admin;

use App\Events\RoomStateChanged;
use App\Http\Controllers\Controller;
use App\Models\AdminAudit;
use App\Models\Room;
use App\Models\RoomMember;
use App\Models\RoomSeat;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class RoomController extends Controller
{
    public function index(Request $request): View
    {
        $query = Room::with('host')->withCount('members')->latest();
        if ($request->query('status') === 'active') $query->whereNull('closed_at');
        if ($request->query('status') === 'closed') $query->whereNotNull('closed_at');
        if ($search = trim((string) $request->query('search'))) {
            $query->where(fn ($q) => $q->where('name', 'like', "%{$search}%")->orWhere('public_id', 'like', "%{$search}%"));
        }
        return view('admin.rooms.index', ['rooms' => $query->paginate(20)->withQueryString(), 'search' => $search ?? '', 'status' => (string) $request->query('status')]);
    }

    public function edit(Room $room): View
    {
        return view('admin.rooms.edit', ['room' => $room->load(['host', 'members.user', 'seats.user'])]);
    }

    public function update(Request $request, Room $room): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'min:2', 'max:80'],
            'language' => ['required', Rule::in(['EN', 'AR'])],
            'tag' => ['required', Rule::in(['chatting', 'gaming', 'music', 'party'])],
            'max_members' => ['required', 'integer', 'min:9', 'max:1000'],
        ]);
        $data['is_featured'] = $request->boolean('is_featured');
        $data['is_locked'] = $request->boolean('is_locked');
        $room->update($data);
        $this->audit($request, 'room.updated', $room);
        $this->broadcast($room);
        return back()->with('success', 'Room updated.');
    }

    public function toggleClosed(Request $request, Room $room): RedirectResponse
    {
        $closing = $room->closed_at === null;
        DB::transaction(function () use ($room, $closing) {
            $room->update(['closed_at' => $closing ? now() : null]);
            if ($closing) {
                RoomMember::where('room_id', $room->id)->where('user_id', '!=', $room->host_user_id)->delete();
                RoomSeat::where('room_id', $room->id)->where('user_id', '!=', $room->host_user_id)->update(['user_id' => null, 'mic_muted' => true]);
            }
        });
        $this->audit($request, $closing ? 'room.closed' : 'room.reopened', $room);
        if (! $closing) $this->broadcast($room);
        return back()->with('success', $closing ? 'Room closed.' : 'Room reopened.');
    }

    public function toggleSeat(Request $request, Room $room, RoomSeat $seat): RedirectResponse
    {
        abort_unless($seat->room_id === $room->id, 404);
        abort_if($seat->position === 1, 409, 'The host seat cannot be locked.');
        $locking = ! $seat->is_locked;
        $seat->update(['is_locked' => $locking, 'user_id' => $locking ? null : $seat->user_id, 'mic_muted' => true]);
        $this->audit($request, $locking ? 'room.seat_locked' : 'room.seat_unlocked', $room, ['position' => $seat->position]);
        $this->broadcast($room);
        return back()->with('success', $locking ? 'Seat locked.' : 'Seat unlocked.');
    }

    public function removeMember(Request $request, Room $room, RoomMember $member): RedirectResponse
    {
        abort_unless($member->room_id === $room->id, 404);
        abort_if($member->user_id === $room->host_user_id, 409, 'The host cannot be removed.');
        DB::transaction(function () use ($room, $member) {
            RoomSeat::where('room_id', $room->id)->where('user_id', $member->user_id)->update(['user_id' => null, 'mic_muted' => true]);
            $member->delete();
        });
        $this->audit($request, 'room.member_removed', $room, ['user_id' => $member->user_id]);
        $this->broadcast($room);
        return back()->with('success', 'Member removed.');
    }

    private function broadcast(Room $room): void { broadcast(new RoomStateChanged($room->fresh(['host', 'members.user', 'seats.user']))); }

    private function audit(Request $request, string $action, Room $room, array $metadata = []): void
    {
        AdminAudit::create(['admin_id' => $request->user()->id, 'action' => $action, 'target_type' => Room::class, 'target_id' => $room->id, 'metadata' => $metadata ?: null, 'ip_address' => $request->ip(), 'user_agent' => $request->userAgent()]);
    }
}
