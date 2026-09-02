<?php
namespace App\Events;
use App\Models\RoomGift;use Illuminate\Broadcasting\{InteractsWithSockets,PresenceChannel};use Illuminate\Contracts\Broadcasting\ShouldBroadcast;use Illuminate\Foundation\Events\Dispatchable;use Illuminate\Queue\SerializesModels;
class RoomGiftSent implements ShouldBroadcast{
 use Dispatchable,InteractsWithSockets,SerializesModels;
 public function __construct(public RoomGift $roomGift){}
 public function broadcastOn():array{return [new PresenceChannel('room.'.$this->roomGift->room->public_id)];}
 public function broadcastAs():string{return 'room.gift';}
 public function broadcastWith():array{$g=$this->roomGift->loadMissing(['gift','sender','recipient']);return ['gift'=>['id'=>$g->id,'emoji'=>$g->gift->emoji,'name_en'=>$g->gift->name_en,'name_ar'=>$g->gift->name_ar,'price'=>$g->price,'sender'=>['id'=>$g->sender->public_id,'name'=>$g->sender->name],'recipient'=>['id'=>$g->recipient->public_id,'name'=>$g->recipient->name]]];}
}
