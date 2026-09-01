<?php

namespace Tests\Feature;

use Illuminate\Http\Testing\File;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
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

    public function test_user_can_list_and_unblock_blocked_accounts(): void
    {
        $me = User::factory()->create();
        $blocked = User::factory()->create(['name' => 'Blocked Person']);
        $me->blockedUsers()->attach($blocked);

        $this->actingAs($me)->getJson('/api/profile/blocked-users')
            ->assertOk()
            ->assertJsonPath('users.0.id', $blocked->public_id)
            ->assertJsonPath('users.0.name', 'Blocked Person');

        $this->actingAs($me)->deleteJson("/api/profiles/{$blocked->public_id}/block")->assertOk();
        $this->assertDatabaseMissing('user_blocks', ['blocker_id' => $me->id, 'blocked_id' => $blocked->id]);
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

    public function test_user_can_upload_and_replace_an_avatar(): void
    {
        Storage::fake('public');
        $user = User::factory()->create();
        $first = $this->actingAs($user)->post('/api/profile/avatar', [
            'avatar' => $this->fakePng('first.png'),
        ])->assertOk()->json('user.avatar_url');
        $oldPath = $user->refresh()->avatar_path;
        Storage::disk('public')->assertExists($oldPath);

        $this->actingAs($user)->post('/api/profile/avatar', [
            'avatar' => $this->fakePng('second.png'),
        ])->assertOk();
        Storage::disk('public')->assertMissing($oldPath);
        $this->assertNotNull($first);
    }

    private function fakePng(string $name): File
    {
        return UploadedFile::fake()->createWithContent(
            $name,
            base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='),
        );
    }
}
