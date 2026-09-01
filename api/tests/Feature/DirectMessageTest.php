<?php
namespace Tests\Feature;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
class DirectMessageTest extends TestCase {
 use RefreshDatabase;
 public function test_users_can_start_send_read_and_mark_a_conversation_read(): void {
  $one=User::factory()->create(['name'=>'One']);$two=User::factory()->create(['name'=>'Two']);
  $id=$this->actingAs($one,'sanctum')->postJson('/api/conversations',['user_id'=>$two->public_id])->assertCreated()->json('conversation.id');
  $this->postJson("/api/conversations/$id/messages",['text'=>'hello'])->assertCreated()->assertJsonPath('message.text','hello');
  $this->actingAs($two,'sanctum')->getJson('/api/conversations')->assertJsonPath('conversations.0.unread_count',1);
  $this->getJson("/api/conversations/$id")->assertOk()->assertJsonPath('messages.0.text','hello');
  $this->getJson('/api/conversations')->assertJsonPath('conversations.0.unread_count',0);
 }
 public function test_outsiders_cannot_access_a_conversation(): void {
  $one=User::factory()->create();$two=User::factory()->create();$out=User::factory()->create();
  $id=$this->actingAs($one,'sanctum')->postJson('/api/conversations',['user_id'=>$two->public_id])->json('conversation.id');
  $this->actingAs($out,'sanctum')->getJson("/api/conversations/$id")->assertForbidden();
  $this->postJson("/api/conversations/$id/messages",['text'=>'x'])->assertForbidden();
 }
 public function test_user_search_excludes_the_caller(): void {
  $me=User::factory()->create(['name'=>'Ashraf']);$other=User::factory()->create(['name'=>'Ashley']);
  $this->actingAs($me,'sanctum')->getJson('/api/users/search?q=Ash')->assertOk()->assertJsonCount(1,'users')->assertJsonPath('users.0.id',$other->public_id);
 }
}
