<?php

namespace Tests\Feature;

use App\Models\Room;
use App\Models\RoomMember;
use App\Models\RoomSeat;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TruthOrDareTest extends TestCase
{
    use RefreshDatabase;

    public function test_host_starts_with_seated_players_and_server_controls_turns(): void
    {
        [$host, $guest, $room] = $this->roomWithTwoSeatedPlayers();
        $session = $this->actingAs($host)->postJson("/api/rooms/{$room->public_id}/games/truth-or-dare")
            ->assertCreated()->json('session');
        $started = $this->actingAs($host)->postJson("/api/game-sessions/{$session['id']}/start")
            ->assertOk()->assertJsonCount(2, 'session.players')->json('session');

        $current = $started['current_player_id'] === $host->public_id ? $host : $guest;
        $other = $current->is($host) ? $guest : $host;
        $this->actingAs($other)->postJson("/api/game-sessions/{$session['id']}/choose", ['type'=>'truth'])->assertForbidden();
        $chosen = $this->actingAs($current)->postJson("/api/game-sessions/{$session['id']}/choose", ['type'=>'truth'])
            ->assertOk()->assertJsonPath('session.current_prompt.type', 'truth')->json('session');
        $this->actingAs($current)->postJson("/api/game-sessions/{$session['id']}/next")
            ->assertOk()->assertJsonPath('session.turn_number', 2)->assertJsonMissingPath('session.current_prompt.text');
        $this->assertNotSame($chosen['current_player_id'], $this->actingAs($host)->getJson("/api/rooms/{$room->public_id}/games/truth-or-dare")->json('session.current_player_id'));
    }

    public function test_prompts_are_localized_and_only_room_members_can_view(): void
    {
        [$host, $guest, $room] = $this->roomWithTwoSeatedPlayers();
        $outsider = User::factory()->create();
        $id = $this->actingAs($host)->postJson("/api/rooms/{$room->public_id}/games/truth-or-dare")->json('session.id');
        $started = $this->actingAs($host)->postJson("/api/game-sessions/$id/start")->json('session');
        $current = $started['current_player_id'] === $host->public_id ? $host : $guest;
        $arabic = $this->actingAs($current)->withHeader('Accept-Language','ar')->postJson("/api/game-sessions/$id/choose", ['type'=>'dare'])
            ->assertOk()->json('session.current_prompt.text');
        $this->assertMatchesRegularExpression('/[\x{0600}-\x{06FF}]/u', $arabic);
        $this->actingAs($outsider)->getJson("/api/rooms/{$room->public_id}/games/truth-or-dare")->assertForbidden();
    }

    public function test_game_requires_two_seated_players(): void
    {
        $host = User::factory()->create();
        $room = Room::create(['host_user_id'=>$host->id,'name'=>'Game Room','language'=>'EN']);
        RoomMember::create(['room_id'=>$room->id,'user_id'=>$host->id,'role'=>'host']);
        RoomSeat::create(['room_id'=>$room->id,'position'=>1,'user_id'=>$host->id]);
        $id = $this->actingAs($host)->postJson("/api/rooms/{$room->public_id}/games/truth-or-dare")->json('session.id');
        $this->actingAs($host)->postJson("/api/game-sessions/$id/start")->assertUnprocessable();
    }

    public function test_admin_can_manage_bilingual_prompts(): void
    {
        $admin=User::factory()->create(['is_admin'=>true]);
        $this->actingAs($admin)->post('/admin/game-prompts',[
            'type'=>'truth','text_en'=>'What made you smile today?','text_ar'=>'ما الذي جعلك تبتسم اليوم؟','minimum_age'=>13,'is_active'=>1,
        ])->assertRedirect();
        $this->assertDatabaseHas('game_prompts',['text_en'=>'What made you smile today?','is_active'=>true]);
        $this->actingAs($admin)->get('/admin/game-prompts')->assertOk()->assertSee('What made you smile today?');
        $this->assertDatabaseHas('admin_audits',['action'=>'game_prompt.created','admin_id'=>$admin->id]);
    }

    private function roomWithTwoSeatedPlayers(): array
    {
        $host=User::factory()->create();$guest=User::factory()->create();
        $room=Room::create(['host_user_id'=>$host->id,'name'=>'Game Room','language'=>'EN']);
        RoomMember::create(['room_id'=>$room->id,'user_id'=>$host->id,'role'=>'host']);
        RoomMember::create(['room_id'=>$room->id,'user_id'=>$guest->id]);
        RoomSeat::create(['room_id'=>$room->id,'position'=>1,'user_id'=>$host->id]);
        RoomSeat::create(['room_id'=>$room->id,'position'=>2,'user_id'=>$guest->id]);
        return [$host,$guest,$room];
    }
}
