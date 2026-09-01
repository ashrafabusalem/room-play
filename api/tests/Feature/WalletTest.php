<?php

namespace Tests\Feature;

use App\Models\CoinTransaction;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use LogicException;
use Tests\TestCase;

class WalletTest extends TestCase
{
    use RefreshDatabase;

    public function test_every_user_gets_a_zero_balance_wallet(): void
    {
        $user = User::factory()->create();
        $this->assertDatabaseHas('coin_wallets', ['user_id' => $user->id, 'balance' => 0]);
        $this->actingAs($user)->getJson('/api/wallet')->assertOk()->assertJsonPath('balance', 0);
    }

    public function test_admin_adjustments_are_atomic_audited_and_visible_to_the_user(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $user = User::factory()->create();
        $this->actingAs($admin)->post("/admin/users/{$user->id}/coins", ['amount' => 500, 'reason' => 'Launch reward'])->assertSessionHas('success');
        $this->actingAs($admin)->post("/admin/users/{$user->id}/coins", ['amount' => -125, 'reason' => 'Correction'])->assertSessionHas('success');

        $this->actingAs($user)->getJson('/api/wallet')
            ->assertJsonPath('balance', 375)
            ->assertJsonPath('transactions.0.amount', -125)
            ->assertJsonPath('transactions.1.balance_after', 500);
        $this->assertDatabaseHas('admin_audits', ['action' => 'wallet.adjusted', 'target_id' => $user->id]);
    }

    public function test_wallet_cannot_go_negative(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $user = User::factory()->create();
        $this->actingAs($admin)->post("/admin/users/{$user->id}/coins", ['amount' => -1, 'reason' => 'Invalid debit'])->assertSessionHasErrors('amount');
        $this->assertDatabaseCount('coin_transactions', 0);
    }

    public function test_ledger_entries_cannot_be_changed_or_deleted(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $user = User::factory()->create();
        $this->actingAs($admin)->post("/admin/users/{$user->id}/coins", ['amount' => 10, 'reason' => 'Test'])->assertSessionHas('success');
        $entry = CoinTransaction::firstOrFail();
        $this->expectException(LogicException::class);
        $entry->delete();
    }
}
