<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AppSetting extends Model
{
    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'registration_enabled' => 'boolean',
            'maintenance_enabled' => 'boolean',
            'force_update' => 'boolean',
            'room_reward_gold' => 'integer',
            'room_reward_cooldown_minutes' => 'integer',
        ];
    }

    public static function current(): self
    {
        return static::query()->firstOrCreate([]);
    }
}
