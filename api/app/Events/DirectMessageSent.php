<?php
namespace App\Events;
use App\Http\Resources\DirectMessageResource;
use App\Models\DirectMessage;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
class DirectMessageSent implements ShouldBroadcast {
 use Dispatchable,InteractsWithSockets,SerializesModels;
 public function __construct(public DirectMessage $message,public string $recipientId) {}
 public function broadcastOn(): array { return [new PrivateChannel('user.'.$this->recipientId)]; }
 public function broadcastAs(): string { return 'direct.message'; }
 public function broadcastWith(): array { return ['conversation_id'=>(string)$this->message->direct_conversation_id,'message'=>(new DirectMessageResource($this->message))->resolve()]; }
}
