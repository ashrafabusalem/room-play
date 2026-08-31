<?php

namespace Tests\Feature;

use App\Models\Room;
use App\Models\RoomMember;
use App\Models\RoomSeat;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RoomTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_a_room_with_nine_server_owned_seats(): void
    {
        $host = User::factory()->create();

        $response = $this->actingAs($host, 'sanctum')->postJson('/api/rooms', [
            'name' => 'Chill & Talk', 'language' => 'EN', 'tag' => 'chatting',
        ])->assertCreated()->assertJsonPath('room.name', 'Chill & Talk')->assertJsonCount(9, 'room.seats');

        $room = Room::where('public_id', $response->json('room.id'))->firstOrFail();
        $this->assertDatabaseHas('room_members', ['room_id' => $room->id, 'user_id' => $host->id, 'role' => 'host']);
        $this->assertDatabaseHas('room_seats', ['room_id' => $room->id, 'position' => 1, 'user_id' => $host->id]);
    }

    public function test_member_must_join_before_taking_a_seat(): void
    {
        [$room, $host] = $this->room();
        $user = User::factory()->create();

        $this->actingAs($user, 'sanctum')->putJson("/api/rooms/{$room->public_id}/seats/2")
            ->assertForbidden();

        $this->postJson("/api/rooms/{$room->public_id}/join")->assertOk();
        $this->putJson("/api/rooms/{$room->public_id}/seats/2")
            ->assertOk()->assertJsonPath('room.seats.1.user.id', $user->public_id);
    }

    public function test_two_users_cannot_occupy_the_same_seat(): void
    {
        [$room] = $this->room();
        $first = User::factory()->create();
        $second = User::factory()->create();
        foreach ([$first, $second] as $user) RoomMember::create(['room_id' => $room->id, 'user_id' => $user->id]);

        $this->actingAs($first, 'sanctum')->putJson("/api/rooms/{$room->public_id}/seats/2")->assertOk();
        $this->actingAs($second, 'sanctum')->putJson("/api/rooms/{$room->public_id}/seats/2")->assertConflict();

        $this->assertSame($first->id, RoomSeat::where('room_id', $room->id)->where('position', 2)->value('user_id'));
    }

    public function test_member_can_move_seats_and_toggle_microphone(): void
    {
        [$room] = $this->room();
        $user = User::factory()->create();
        RoomMember::create(['room_id' => $room->id, 'user_id' => $user->id]);

        $this->actingAs($user, 'sanctum')->putJson("/api/rooms/{$room->public_id}/seats/2")->assertOk();
        $this->putJson("/api/rooms/{$room->public_id}/seats/3")->assertOk();
        $this->patchJson("/api/rooms/{$room->public_id}/microphone", ['muted' => false])->assertOk();

        $this->assertDatabaseHas('room_seats', ['room_id' => $room->id, 'position' => 2, 'user_id' => null]);
        $this->assertDatabaseHas('room_seats', ['room_id' => $room->id, 'position' => 3, 'user_id' => $user->id, 'mic_muted' => false]);
    }

    public function test_leaving_room_releases_seat_and_membership(): void
    {
        [$room] = $this->room();
        $user = User::factory()->create();
        RoomMember::create(['room_id' => $room->id, 'user_id' => $user->id]);
        RoomSeat::where('room_id', $room->id)->where('position', 2)->update(['user_id' => $user->id]);

        $this->actingAs($user, 'sanctum')->deleteJson("/api/rooms/{$room->public_id}/leave")->assertOk();
        $this->assertDatabaseMissing('room_members', ['room_id' => $room->id, 'user_id' => $user->id]);
        $this->assertDatabaseHas('room_seats', ['room_id' => $room->id, 'position' => 2, 'user_id' => null]);
    }

    public function test_room_routes_require_authentication(): void
    {
        $this->getJson('/api/rooms')->assertUnauthorized();
        $this->postJson('/api/broadcasting/auth')->assertUnauthorized();
    }

    private function room(): array
    {
        $host = User::factory()->create();
        $room = Room::create(['host_user_id' => $host->id, 'name' => 'Room', 'language' => 'EN']);
        RoomMember::create(['room_id' => $room->id, 'user_id' => $host->id, 'role' => 'host']);
        foreach (range(1, 9) as $position) RoomSeat::create(['room_id' => $room->id, 'position' => $position, 'user_id' => $position === 1 ? $host->id : null]);
        return [$room, $host];
    }
}
