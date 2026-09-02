<?php

namespace App\Events;

use App\Http\Resources\RoomResource;
use App\Models\Room;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class RoomStateChanged implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public Room $room) {}

    public function broadcastOn(): array
    {
        return [new PresenceChannel('room.'.$this->room->public_id)];
    }

    public function broadcastAs(): string { return 'room.updated'; }

    public function broadcastWith(): array
    {
        return ['room' => (new RoomResource($this->room))->resolve()];
    }
}
