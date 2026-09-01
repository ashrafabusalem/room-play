<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use LogicException;

class CoinTransaction extends Model
{
    public const UPDATED_AT = null;
    protected $guarded = [];
    protected function casts(): array { return ['amount' => 'integer', 'balance_after' => 'integer', 'metadata' => 'array']; }
    protected static function booted(): void
    {
        static::updating(fn () => throw new LogicException('Coin transactions are append-only.'));
        static::deleting(fn () => throw new LogicException('Coin transactions are append-only.'));
    }
    public function wallet() { return $this->belongsTo(CoinWallet::class, 'wallet_id'); }
    public function creator() { return $this->belongsTo(User::class, 'created_by')->withTrashed(); }
}
