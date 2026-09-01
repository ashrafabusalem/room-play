<?php

namespace Tests\Feature;

use App\Models\FriendRequest;
use App\Models\Room;
use App\Models\RoomMember;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SocialTest extends TestCase
{
    use RefreshDatabase;

    public function test_friend_request_can_be_sent_accepted_listed_and_removed(): void
    {
        $one = User::factory()->create();
        $two = User::factory()->create();
        $this->actingAs($one)->postJson("/api/friend-requests/{$two->public_id}")->assertCreated();
        $this->actingAs($one)->getJson("/api/profiles/{$two->public_id}")
            ->assertJsonPath('profile.friendship_status', 'pending')
            ->assertJsonPath('profile.friend_request_direction', 'sent');
        $request = FriendRequest::firstOrFail();
        $this->actingAs($two)->getJson('/api/friend-requests')->assertJsonPath('requests.0.user.id', $one->public_id);
        $this->actingAs($two)->patchJson("/api/friend-requests/{$request->id}", ['accept' => true])->assertOk();
        $this->actingAs($one)->getJson("/api/profiles/{$two->public_id}")->assertJsonPath('profile.friendship_status', 'accepted');
        $this->actingAs($one)->getJson('/api/friends')->assertJsonPath('friends.0.id', $two->public_id);
        $this->actingAs($one)->deleteJson("/api/friends/{$two->public_id}")->assertOk();
        $this->assertDatabaseMissing('friend_requests', ['id' => $request->id]);
    }

    public function test_only_friends_can_be_invited_and_accepting_joins_the_room(): void
    {
        $host = User::factory()->create();
        $friend = User::factory()->create();
        $stranger = User::factory()->create();
        $room = Room::create(['host_user_id' => $host->id, 'name' => 'Friends Room', 'language' => 'EN']);
        RoomMember::create(['room_id' => $room->id, 'user_id' => $host->id, 'role' => 'host']);
        FriendRequest::create(['requester_id' => $host->id, 'addressee_id' => $friend->id, 'status' => 'accepted', 'responded_at' => now()]);

        $this->actingAs($host)->postJson("/api/rooms/{$room->public_id}/invitations/{$stranger->public_id}")->assertForbidden();
        $this->actingAs($host)->postJson("/api/rooms/{$room->public_id}/invitations/{$friend->public_id}")->assertCreated();
        $invitationId = $this->actingAs($friend)->getJson('/api/room-invitations')->assertJsonPath('invitations.0.room.id', $room->public_id)->json('invitations.0.id');
        $this->actingAs($friend)->patchJson("/api/room-invitations/{$invitationId}", ['accept' => true])->assertOk();
        $this->assertDatabaseHas('room_members', ['room_id' => $room->id, 'user_id' => $friend->id]);
    }

    public function test_blocking_removes_friendship(): void
    {
        $one = User::factory()->create();
        $two = User::factory()->create();
        FriendRequest::create(['requester_id' => $one->id, 'addressee_id' => $two->id, 'status' => 'accepted']);
        $this->actingAs($one)->postJson("/api/profiles/{$two->public_id}/block")->assertOk();
        $this->assertDatabaseCount('friend_requests', 0);
    }
}
