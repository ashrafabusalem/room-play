<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProfileTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_update_and_view_a_profile(): void
    {
        $me = User::factory()->create();
        $other = User::factory()->create(['name' => 'Other']);

        $this->actingAs($me)->patchJson('/api/profile', ['bio' => 'Hello', 'dm_privacy' => 'followers'])
            ->assertOk()->assertJsonPath('user.bio', 'Hello');
        $this->actingAs($me)->getJson("/api/profiles/{$other->public_id}")
            ->assertOk()->assertJsonPath('profile.name', 'Other')->assertJsonPath('profile.is_following', false);
    }

    public function test_follow_block_and_unblock_are_server_owned(): void
    {
        $me = User::factory()->create();
        $other = User::factory()->create();

        $this->actingAs($me)->postJson("/api/profiles/{$other->public_id}/follow")->assertOk();
        $this->assertDatabaseHas('user_follows', ['follower_id' => $me->id, 'followed_id' => $other->id]);
        $this->actingAs($me)->postJson("/api/profiles/{$other->public_id}/block")->assertOk();
        $this->assertDatabaseMissing('user_follows', ['follower_id' => $me->id, 'followed_id' => $other->id]);
        $this->assertDatabaseHas('user_blocks', ['blocker_id' => $me->id, 'blocked_id' => $other->id]);
        $this->actingAs($me)->deleteJson("/api/profiles/{$other->public_id}/block")->assertOk();
    }

    public function test_blocking_and_privacy_prevent_direct_messages(): void
    {
        $sender = User::factory()->create();
        $recipient = User::factory()->create(['dm_privacy' => 'nobody']);
        $this->actingAs($sender)->postJson('/api/conversations', ['user_id' => $recipient->public_id])->assertForbidden();

        $recipient->forceFill(['dm_privacy' => 'followers'])->save();
        $this->actingAs($sender)->postJson('/api/conversations', ['user_id' => $recipient->public_id])->assertForbidden();
        $this->actingAs($sender)->postJson("/api/profiles/{$recipient->public_id}/follow")->assertOk();
        $this->actingAs($sender)->postJson('/api/conversations', ['user_id' => $recipient->public_id])->assertCreated();
    }

    public function test_user_can_report_another_user(): void
    {
        $reporter = User::factory()->create();
        $reported = User::factory()->create();
        $this->actingAs($reporter)->postJson("/api/profiles/{$reported->public_id}/reports", ['reason' => 'spam', 'details' => 'Repeated ads'])->assertCreated();
        $this->assertDatabaseHas('user_reports', ['reporter_id' => $reporter->id, 'reported_id' => $reported->id, 'status' => 'pending']);
    }
}
