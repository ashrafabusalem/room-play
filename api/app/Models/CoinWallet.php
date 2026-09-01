<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CoinWallet extends Model
{
    protected $guarded = [];
    protected function casts(): array { return ['balance' => 'integer', 'version' => 'integer']; }
    public function user() { return $this->belongsTo(User::class); }
    public function transactions() { return $this->hasMany(CoinTransaction::class, 'wallet_id')->latest('id'); }
}
