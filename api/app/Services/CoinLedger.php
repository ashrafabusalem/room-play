<?php

namespace App\Services;

use App\Models\CoinTransaction;
use App\Models\CoinWallet;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class CoinLedger
{
    public function post(User $user, int $amount, string $type, string $description, ?User $actor = null, ?array $metadata = null): CoinTransaction
    {
        if ($amount === 0) throw ValidationException::withMessages(['amount' => 'Amount cannot be zero.']);
        return DB::transaction(function () use ($user, $amount, $type, $description, $actor, $metadata) {
            CoinWallet::firstOrCreate(['user_id' => $user->id]);
            $wallet = CoinWallet::where('user_id', $user->id)->lockForUpdate()->firstOrFail();
            $next = $wallet->balance + $amount;
            if ($next < 0) throw ValidationException::withMessages(['amount' => 'This adjustment would make the balance negative.']);
            $wallet->update(['balance' => $next, 'version' => $wallet->version + 1]);
            return CoinTransaction::create([
                'reference' => (string) Str::uuid(), 'wallet_id' => $wallet->id,
                'amount' => $amount, 'balance_after' => $next, 'type' => $type,
                'description' => $description, 'metadata' => $metadata, 'created_by' => $actor?->id,
            ]);
        });
    }
}
