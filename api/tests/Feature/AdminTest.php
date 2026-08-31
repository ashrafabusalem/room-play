<?php

namespace Tests\Feature;

use App\Models\AdminAudit;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AdminTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_panel_requires_an_administrator(): void
    {
        $this->get('/admin')->assertRedirect('/admin/login');

        $user = User::factory()->create();
        $this->actingAs($user)->get('/admin')->assertForbidden();

        $admin = User::factory()->create(['is_admin' => true]);
        $this->actingAs($admin)->get('/admin')->assertOk();
    }

    public function test_only_an_active_admin_can_sign_in(): void
    {
        User::factory()->create(['email' => 'user@example.com', 'password' => 'password']);
        $this->post('/admin/login', ['email' => 'user@example.com', 'password' => 'password'])
            ->assertSessionHasErrors('email');

        $admin = User::factory()->create(['email' => 'admin@example.com', 'password' => 'password', 'is_admin' => true]);
        $this->post('/admin/login', ['email' => $admin->email, 'password' => 'password'])
            ->assertRedirect('/admin');
        $this->assertAuthenticatedAs($admin);
        $this->assertDatabaseHas('admin_audits', ['action' => 'admin.login', 'admin_id' => $admin->id]);
    }

    public function test_blocking_a_user_revokes_tokens_and_prevents_login(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $user = User::factory()->create(['email' => 'blocked@example.com', 'password' => 'password']);
        $user->createToken('phone');

        $this->actingAs($admin)->post("/admin/users/{$user->id}/block")->assertSessionHas('success');

        $user->refresh();
        $this->assertNotNull($user->blocked_at);
        $this->assertCount(0, $user->tokens);
        $this->postJson('/api/login', ['email' => $user->email, 'password' => 'password'])->assertUnprocessable();
        $this->assertDatabaseHas('admin_audits', ['action' => 'user.blocked', 'target_id' => $user->id]);
    }

    public function test_changing_password_revokes_tokens_and_marks_it_temporary(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $user = User::factory()->create();
        $user->createToken('phone');

        $this->actingAs($admin)->put("/admin/users/{$user->id}/password", [
            'password' => 'new-password-123',
            'password_confirmation' => 'new-password-123',
        ])->assertSessionHas('success');

        $user->refresh();
        $this->assertTrue(Hash::check('new-password-123', $user->password));
        $this->assertTrue($user->must_change_password);
        $this->assertCount(0, $user->tokens);
    }

    public function test_deleting_a_user_is_recoverable_and_audited(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $user = User::factory()->create();

        $this->actingAs($admin)->delete("/admin/users/{$user->id}")->assertRedirect('/admin/users');
        $this->assertSoftDeleted($user);
        $this->assertTrue(AdminAudit::where('action', 'user.deleted')->where('target_id', $user->id)->exists());

        $this->actingAs($admin)->post("/admin/users/{$user->id}/restore")->assertSessionHas('success');
        $this->assertNotSoftDeleted($user);
    }

    public function test_admin_can_replace_their_temporary_password(): void
    {
        $admin = User::factory()->create([
            'is_admin' => true,
            'password' => 'temporary-123',
            'must_change_password' => true,
        ]);

        $this->actingAs($admin)->put('/admin/account/password', [
            'current_password' => 'temporary-123',
            'password' => 'private-password-456',
            'password_confirmation' => 'private-password-456',
        ])->assertSessionHas('success');

        $admin->refresh();
        $this->assertFalse($admin->must_change_password);
        $this->assertTrue(Hash::check('private-password-456', $admin->password));
    }

    public function test_admin_can_view_and_search_the_audit_log(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        AdminAudit::create(['admin_id' => $admin->id, 'action' => 'user.blocked']);

        $this->actingAs($admin)->get('/admin/audit?search=blocked')
            ->assertOk()
            ->assertSee('User Blocked')
            ->assertSee($admin->email);
    }
}
