<?php

namespace Tests\Feature;

use App\Models\GameSession;
use App\Models\Room;
use App\Models\RoomMember;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class GameRequestTest extends TestCase
{
    use RefreshDatabase;

    public function test_member_requests_and_host_accepts_a_game(): void
    {
        $host = User::factory()->create();
        $member = User::factory()->create();
        $room = Room::create(['name' => 'Games', 'host_user_id' => $host->id]);
        RoomMember::create(['room_id' => $room->id, 'user_id' => $host->id, 'role' => 'host']);
        RoomMember::create(['room_id' => $room->id, 'user_id' => $member->id]);

        $request = $this->actingAs($member, 'sanctum')
            ->postJson("/api/rooms/{$room->public_id}/game-requests", ['game' => 'spy'])
            ->assertCreated()->assertJsonPath('request.requester.name', $member->name);

        $id = $request->json('request.id');
        $this->actingAs($host, 'sanctum')
            ->getJson("/api/rooms/{$room->public_id}/game-requests/pending")
            ->assertOk()->assertJsonPath('request.id', $id);
        $this->patchJson("/api/game-requests/{$id}", ['action' => 'accept'])
            ->assertOk()->assertJsonPath('request.status', 'accepted');

        $this->assertDatabaseHas('game_sessions', [
            'room_id' => $room->id,
            'game' => 'spy',
            'status' => 'lobby',
            'host_user_id' => $host->id,
        ]);
    }

    public function test_only_host_can_view_or_answer_requests(): void
    {
        $host = User::factory()->create();
        $member = User::factory()->create();
        $room = Room::create(['name' => 'Games', 'host_user_id' => $host->id]);
        RoomMember::create(['room_id' => $room->id, 'user_id' => $host->id, 'role' => 'host']);
        RoomMember::create(['room_id' => $room->id, 'user_id' => $member->id]);

        $id = $this->actingAs($member, 'sanctum')
            ->postJson("/api/rooms/{$room->public_id}/game-requests", ['game' => 'truth_or_dare'])
            ->json('request.id');
        $this->getJson("/api/rooms/{$room->public_id}/game-requests/pending")->assertForbidden();
        $this->patchJson("/api/game-requests/{$id}", ['action' => 'accept'])->assertForbidden();
        $this->assertDatabaseCount('game_sessions', 0);
    }
}
