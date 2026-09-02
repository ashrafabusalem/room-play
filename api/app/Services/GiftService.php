<?php
namespace App\Services;
use App\Models\{CoinTransaction,CoinWallet,Gift,Room,RoomGift,User};
use Illuminate\Support\Facades\DB;
use Illuminate\Database\QueryException;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
class GiftService {
 public function send(Room $room,Gift $gift,User $sender,User $recipient,string $requestId):array{
  try{return DB::transaction(function()use($room,$gift,$sender,$recipient,$requestId){
   $existing=RoomGift::where(['sender_id'=>$sender->id,'request_id'=>$requestId])->lockForUpdate()->first();if($existing)return [$existing,false];
   abort_unless($gift->is_active,404); abort_if($sender->is($recipient),422,'Choose another recipient.');
   $memberIds=$room->members()->pluck('user_id'); abort_unless($memberIds->contains($sender->id)&&$memberIds->contains($recipient->id),403,'Both users must be in the room.');
   CoinWallet::firstOrCreate(['user_id'=>$sender->id]); CoinWallet::firstOrCreate(['user_id'=>$recipient->id]);
   $wallets=CoinWallet::whereIn('user_id',[$sender->id,$recipient->id])->orderBy('user_id')->lockForUpdate()->get()->keyBy('user_id');
   $from=$wallets[$sender->id];$to=$wallets[$recipient->id]; if($from->balance<$gift->price)throw ValidationException::withMessages(['balance'=>'Not enough Gold.']);
   $from->update(['balance'=>$from->balance-$gift->price,'version'=>$from->version+1]);$to->update(['balance'=>$to->balance+$gift->price,'version'=>$to->version+1]);
   $meta=['gift_id'=>$gift->id,'room_id'=>$room->public_id,'other_user_id'=>$recipient->public_id];
   CoinTransaction::create(['reference'=>(string)Str::uuid(),'wallet_id'=>$from->id,'amount'=>-$gift->price,'balance_after'=>$from->balance,'type'=>'gift_sent','description'=>'Gift sent: '.$gift->name_en,'metadata'=>$meta]);
   $meta['other_user_id']=$sender->public_id;CoinTransaction::create(['reference'=>(string)Str::uuid(),'wallet_id'=>$to->id,'amount'=>$gift->price,'balance_after'=>$to->balance,'type'=>'gift_received','description'=>'Gift received: '.$gift->name_en,'metadata'=>$meta]);
   return [RoomGift::create(['room_id'=>$room->id,'gift_id'=>$gift->id,'sender_id'=>$sender->id,'recipient_id'=>$recipient->id,'request_id'=>$requestId,'price'=>$gift->price]),true];
  });}catch(QueryException $e){$existing=RoomGift::where(['sender_id'=>$sender->id,'request_id'=>$requestId])->first();if($existing)return [$existing,false];throw $e;}
 }
}
