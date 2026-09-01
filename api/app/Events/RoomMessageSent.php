<?php

namespace App\Events;

use App\Http\Resources\RoomMessageResource;
use App\Models\RoomMessage;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class RoomMessageSent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public function __construct(public RoomMessage $message) {}
    public function broadcastOn(): array { return [new PresenceChannel('room.'.$this->message->room->public_id)]; }
    public function broadcastAs(): string { return 'room.message'; }
    public function broadcastWith(): array { return ['message' => (new RoomMessageResource($this->message))->resolve()]; }
}
