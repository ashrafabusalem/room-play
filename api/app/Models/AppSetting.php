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
        ];
    }

    public static function current(): self
    {
        return static::query()->firstOrCreate([]);
    }
}
