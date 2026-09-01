<?php

namespace Tests\Feature;

use App\Models\Room;
use App\Models\RoomMember;
use App\Models\RoomSeat;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SpyGameTest extends TestCase
{
    use RefreshDatabase;

    public function test_server_hides_the_word_from_exactly_one_spy_until_reveal(): void
    {
        [$room, $players] = $this->room();
        $id = $this->actingAs($players[0])->postJson("/api/rooms/{$room->public_id}/games/spy")
            ->assertCreated()->json('session.id');
        $this->postJson("/api/spy-game-sessions/$id/start")->assertOk()->assertJsonCount(3, 'session.players');

        $states = collect($players)->map(fn ($player) => $this->actingAs($player)
            ->getJson("/api/rooms/{$room->public_id}/games/spy")->assertOk()->json('session'));
        $spyState = $states->firstWhere('is_spy', true);
        $this->assertNull($spyState['word']);
        $this->assertCount(1, $states->where('is_spy', true));
        $this->assertCount(1, $states->where('is_spy', false)->pluck('word')->unique());

        $revealed = $this->actingAs($players[0])->postJson("/api/spy-game-sessions/$id/reveal")
            ->assertOk()->assertJsonPath('session.status', 'revealed')->json('session');
        $this->assertNotNull($revealed['spy']['id']);
        $this->assertNotNull($revealed['word']);
    }

    public function test_only_host_can_start_and_three_seated_players_are_required(): void
    {
        [$room, $players] = $this->room();
        $id = $this->actingAs($players[0])->postJson("/api/rooms/{$room->public_id}/games/spy")->json('session.id');
        $this->actingAs($players[1])->postJson("/api/spy-game-sessions/$id/start")->assertForbidden();
        RoomSeat::where('room_id', $room->id)->where('position', 3)->update(['user_id' => null]);
        $this->actingAs($players[0])->postJson("/api/spy-game-sessions/$id/start")->assertUnprocessable();
    }

    public function test_admin_can_manage_bilingual_spy_words(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $this->actingAs($admin)->post('/admin/game-prompts', [
            'game' => 'spy', 'type' => 'word', 'text_en' => 'Museum', 'text_ar' => 'متحف',
            'minimum_age' => 13, 'is_active' => 1,
        ])->assertRedirect();
        $this->assertDatabaseHas('game_prompts', ['game' => 'spy', 'text_en' => 'Museum']);
        $this->actingAs($admin)->get('/admin/game-prompts?game=spy')->assertOk()->assertSee('Museum');
    }

    private function room(): array
    {
        $players = User::factory()->count(3)->create();
        $room = Room::create(['host_user_id' => $players[0]->id, 'name' => 'Spy Room', 'language' => 'EN']);
        foreach ($players as $index => $player) {
            RoomMember::create(['room_id' => $room->id, 'user_id' => $player->id, 'role' => $index === 0 ? 'host' : 'member']);
            RoomSeat::create(['room_id' => $room->id, 'position' => $index + 1, 'user_id' => $player->id]);
        }

        return [$room, $players];
    }
}
