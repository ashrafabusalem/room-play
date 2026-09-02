<?php
namespace Tests\Feature;
use App\Models\{Gift,Room,RoomMember,User};use App\Services\CoinLedger;use Illuminate\Foundation\Testing\RefreshDatabase;use Tests\TestCase;
class GiftTest extends TestCase{use RefreshDatabase;
 public function test_gift_transfer_is_atomic_and_append_only():void{
  $sender=User::factory()->create();$recipient=User::factory()->create();$room=Room::create(['name'=>'Party','host_user_id'=>$sender->id]);
  RoomMember::create(['room_id'=>$room->id,'user_id'=>$sender->id]);RoomMember::create(['room_id'=>$room->id,'user_id'=>$recipient->id]);
  $gift=Gift::create(['name_en'=>'Rose','name_ar'=>'وردة','emoji'=>'🌹','price'=>40,'is_active'=>true]);app(CoinLedger::class)->post($sender,100,'test','Test credit');
  $payload=['recipient_id'=>$recipient->public_id,'request_id'=>'gift-request-1'];
  $this->actingAs($sender)->postJson("/api/rooms/{$room->public_id}/gifts/{$gift->id}",$payload)->assertCreated()->assertJsonPath('balance',60)->assertJsonPath('recipient_balance',40);
  $this->postJson("/api/rooms/{$room->public_id}/gifts/{$gift->id}",$payload)->assertOk()->assertJsonPath('balance',60)->assertJsonPath('recipient_balance',40);
  $this->assertSame(60,$sender->wallet->refresh()->balance);$this->assertSame(40,$recipient->wallet->refresh()->balance);
  $this->assertDatabaseHas('coin_transactions',['wallet_id'=>$sender->wallet->id,'amount'=>-40,'type'=>'gift_sent']);
  $this->assertDatabaseHas('coin_transactions',['wallet_id'=>$recipient->wallet->id,'amount'=>40,'type'=>'gift_received']);
  $this->assertDatabaseHas('app_notifications',['user_id'=>$recipient->id,'actor_id'=>$sender->id,'type'=>'gift_received']);
  $this->assertDatabaseCount('room_gifts',1);$this->assertDatabaseCount('app_notifications',1);
 }
 public function test_gift_rejects_insufficient_gold_and_non_member_recipient():void{
  $sender=User::factory()->create();$recipient=User::factory()->create();$room=Room::create(['name'=>'Party','host_user_id'=>$sender->id]);RoomMember::create(['room_id'=>$room->id,'user_id'=>$sender->id]);
  $gift=Gift::create(['name_en'=>'Crown','name_ar'=>'تاج','emoji'=>'👑','price'=>100,'is_active'=>true]);
  $payload=['recipient_id'=>$recipient->public_id,'request_id'=>'gift-request-2'];
  $this->actingAs($sender)->postJson("/api/rooms/{$room->public_id}/gifts/{$gift->id}",$payload)->assertForbidden();
  RoomMember::create(['room_id'=>$room->id,'user_id'=>$recipient->id]);$this->actingAs($sender)->postJson("/api/rooms/{$room->public_id}/gifts/{$gift->id}",$payload)->assertUnprocessable();
  $this->assertDatabaseCount('room_gifts',0);
 }
}
