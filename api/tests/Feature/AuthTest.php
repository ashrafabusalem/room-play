<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\AppSetting;
use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\RateLimiter;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_registration_can_be_disabled_by_an_administrator(): void
    {
        AppSetting::current()->update(['registration_enabled' => false]);

        $this->postJson('/api/register', [
            'name' => 'Alex',
            'email' => 'alex@example.com',
            'password' => 'password-123',
            'password_confirmation' => 'password-123',
        ])->assertForbidden()->assertJsonPath('message', 'New registrations are temporarily closed.');

        $this->assertDatabaseMissing('users', ['email' => 'alex@example.com']);
    }

    protected function setUp(): void
    {
        parent::setUp();

        // The login limiter is keyed on email + IP and lives in the cache, so
        // it outlives a database refresh — without this, later tests inherit
        // earlier tests' failed attempts.
        RateLimiter::clear('alex@example.com|127.0.0.1');
        RateLimiter::clear('nobody@example.com|127.0.0.1');
    }

    // --------------------------------------------------------------- register

    public function test_registers_a_user_and_returns_a_token(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Alex',
            'email' => 'alex@example.com',
            'password' => 'correct-horse',
            'device_name' => 'Pixel 8',
        ]);

        $response->assertCreated()
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email', 'level']])
            ->assertJsonPath('user.name', 'Alex')
            ->assertJsonPath('user.email', 'alex@example.com')
            ->assertJsonPath('user.level', 1);

        $this->assertDatabaseHas('users', ['email' => 'alex@example.com']);
    }

    public function test_never_returns_the_password_hash(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Alex',
            'email' => 'alex@example.com',
            'password' => 'correct-horse',
        ]);

        $this->assertArrayNotHasKey('password', $response->json('user'));
    }

    public function test_gives_each_user_a_distinct_public_id(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();

        $this->assertNotNull($a->public_id);
        $this->assertNotSame($a->public_id, $b->public_id);
        $this->assertMatchesRegularExpression('/^[1-9][0-9]{5}$/', $a->public_id);
    }

    public function test_rejects_a_duplicate_email(): void
    {
        User::factory()->create(['email' => 'alex@example.com']);

        $this->postJson('/api/register', [
            'name' => 'Alex',
            'email' => 'alex@example.com',
            'password' => 'correct-horse',
        ])->assertStatus(422)->assertJsonValidationErrors('email');
    }

    public function test_normalises_the_email_before_storing_it(): void
    {
        $this->postJson('/api/register', [
            'name' => 'Alex',
            'email' => '  ALEX@Example.COM  ',
            'password' => 'correct-horse',
        ])->assertCreated();

        $this->assertDatabaseHas('users', ['email' => 'alex@example.com']);
    }

    public function test_rejects_a_short_password(): void
    {
        $this->postJson('/api/register', [
            'name' => 'Alex',
            'email' => 'alex@example.com',
            'password' => 'short',
        ])->assertStatus(422)->assertJsonValidationErrors('password');
    }

    public function test_rejects_a_short_name(): void
    {
        $this->postJson('/api/register', [
            'name' => 'ab',
            'email' => 'alex@example.com',
            'password' => 'correct-horse',
        ])->assertStatus(422)->assertJsonValidationErrors('name');
    }

    public function test_ignores_level_and_public_id_sent_by_the_client(): void
    {
        $this->postJson('/api/register', [
            'name' => 'Alex',
            'email' => 'alex@example.com',
            'password' => 'correct-horse',
            'level' => 99,
            'public_id' => '000001',
        ])->assertCreated()->assertJsonPath('user.level', 1);

        $this->assertNotSame('000001', User::first()->public_id);
    }

    // ------------------------------------------------------------------ login

    public function test_logs_in_with_correct_credentials(): void
    {
        User::factory()->create([
            'email' => 'alex@example.com',
            'password' => 'correct-horse',
        ]);

        $this->postJson('/api/login', [
            'email' => 'alex@example.com',
            'password' => 'correct-horse',
        ])->assertOk()
            ->assertJsonStructure(['token', 'user'])
            ->assertJsonPath('user.email', 'alex@example.com');
    }

    public function test_rejects_a_wrong_password(): void
    {
        User::factory()->create([
            'email' => 'alex@example.com',
            'password' => 'correct-horse',
        ]);

        $this->postJson('/api/login', [
            'email' => 'alex@example.com',
            'password' => 'wrong-horse',
        ])->assertStatus(422)->assertJsonValidationErrors('email');
    }

    public function test_unknown_email_answers_the_same_as_a_wrong_password(): void
    {
        User::factory()->create([
            'email' => 'alex@example.com',
            'password' => 'correct-horse',
        ]);

        $wrongPassword = $this->postJson('/api/login', [
            'email' => 'alex@example.com',
            'password' => 'wrong-horse',
        ]);

        $noSuchUser = $this->postJson('/api/login', [
            'email' => 'nobody@example.com',
            'password' => 'wrong-horse',
        ]);

        // Any difference between these two is an account-enumeration hole.
        $this->assertSame($wrongPassword->status(), $noSuchUser->status());
        $this->assertSame(
            $wrongPassword->json('message'),
            $noSuchUser->json('message')
        );
    }

    public function test_locks_out_after_five_failed_attempts(): void
    {
        User::factory()->create([
            'email' => 'alex@example.com',
            'password' => 'correct-horse',
        ]);

        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/login', [
                'email' => 'alex@example.com',
                'password' => 'wrong-horse',
            ])->assertStatus(422);
        }

        // The sixth attempt is refused even though the password is now correct.
        $this->postJson('/api/login', [
            'email' => 'alex@example.com',
            'password' => 'correct-horse',
        ])->assertStatus(422)->assertJsonValidationErrors('email');
    }

    // ------------------------------------------------------------ me / logout

    public function test_returns_the_signed_in_user(): void
    {
        $user = User::factory()->create(['name' => 'Alex']);

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/me')
            ->assertOk()
            // Same `user` key as register and login, not a bare resource's
            // `data` wrapper.
            ->assertJsonPath('user.name', 'Alex')
            ->assertJsonMissingPath('data');
    }

    public function test_refuses_an_unauthenticated_request(): void
    {
        $this->getJson('/api/me')->assertUnauthorized();
    }

    public function test_unauthenticated_api_request_without_accept_header_is_json(): void
    {
        $this->get('/api/me')
            ->assertUnauthorized()
            ->assertJson(['message' => 'Unauthenticated.']);
    }

    public function test_revokes_only_the_token_that_signed_out(): void
    {
        $user = User::factory()->create();
        $phone = $user->createToken('phone')->plainTextToken;
        $tablet = $user->createToken('tablet')->plainTextToken;

        $this->withHeader('Authorization', "Bearer {$phone}")
            ->postJson('/api/logout')
            ->assertOk();

        // Production boots a fresh container per request, so the revoked token
        // simply fails to resolve. A test reuses one container and the guard
        // caches the user it already authenticated — clear it, or this asserts
        // against a stale in-memory session rather than the database.
        $this->app['auth']->forgetGuards();

        $this->withHeader('Authorization', "Bearer {$phone}")
            ->getJson('/api/me')
            ->assertUnauthorized();

        $this->app['auth']->forgetGuards();

        // The other device stays signed in.
        $this->withHeader('Authorization', "Bearer {$tablet}")
            ->getJson('/api/me')
            ->assertOk();
    }

    // ----------------------------------------------------------- reset e-mail

    public function test_emails_a_reset_link_to_a_known_address(): void
    {
        Notification::fake();
        $user = User::factory()->create(['email' => 'alex@example.com']);

        $this->postJson('/api/forgot-password', ['email' => 'alex@example.com'])
            ->assertOk();

        Notification::assertSentTo($user, ResetPassword::class);
    }

    public function test_reports_success_for_an_unknown_address_without_sending_mail(): void
    {
        Notification::fake();

        $this->postJson('/api/forgot-password', ['email' => 'nobody@example.com'])
            ->assertOk();

        Notification::assertNothingSent();
    }
}
