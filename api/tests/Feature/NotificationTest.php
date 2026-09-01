<?php
namespace Tests\Feature;
use App\Models\AppNotification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
class NotificationTest extends TestCase {
 use RefreshDatabase;
 public function test_follow_and_friend_request_create_persistent_notifications():void{
  $one=User::factory()->create(['name'=>'One']);$two=User::factory()->create();
  $this->actingAs($one)->postJson("/api/profiles/{$two->public_id}/follow")->assertOk();
  $this->actingAs($one)->postJson("/api/friend-requests/{$two->public_id}")->assertCreated();
  $this->actingAs($two)->getJson('/api/notifications')->assertOk()->assertJsonPath('unread_count',2)->assertJsonFragment(['type'=>'friend_request'])->assertJsonFragment(['type'=>'new_follower'])->assertJsonFragment(['name'=>'One']);
 }
 public function test_user_can_read_one_or_all_but_not_another_users_notification():void{
  $user=User::factory()->create();$other=User::factory()->create();
  $mine=AppNotification::create(['user_id'=>$user->id,'type'=>'new_follower']);
  $theirs=AppNotification::create(['user_id'=>$other->id,'type'=>'new_follower']);
  $this->actingAs($user)->patchJson("/api/notifications/{$theirs->id}")->assertForbidden();
  $this->actingAs($user)->patchJson("/api/notifications/{$mine->id}")->assertOk();
  $this->assertNotNull($mine->refresh()->read_at);
  AppNotification::create(['user_id'=>$user->id,'type'=>'friend_request']);
  $this->actingAs($user)->patchJson('/api/notifications/read-all')->assertOk();
  $this->assertSame(0,AppNotification::where('user_id',$user->id)->whereNull('read_at')->count());
 }
}
