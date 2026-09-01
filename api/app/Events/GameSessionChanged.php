<?php
namespace App\Events;
use App\Models\GameSession;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
class GameSessionChanged implements ShouldBroadcastNow {
 use Dispatchable,InteractsWithSockets,SerializesModels;
 public function __construct(public GameSession $session){}
 public function broadcastOn():array{return [new PresenceChannel('room.'.$this->session->room->public_id)];}
 public function broadcastAs():string{return 'game.updated';}
 public function broadcastWith():array{return ['game'=>'truth_or_dare','session_id'=>$this->session->public_id];}
}
