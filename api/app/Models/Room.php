<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Room extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $attributes = [
        'language' => 'EN',
        'tag' => 'chatting',
        'seat_count' => 9,
        'max_members' => 100,
        'is_featured' => false,
        'is_locked' => false,
    ];

    protected function casts(): array
    {
        return ['is_featured' => 'boolean', 'is_locked' => 'boolean', 'closed_at' => 'datetime'];
    }

    protected static function booted(): void
    {
        static::creating(function (Room $room) {
            do {
                $room->public_id = (string) random_int(100000, 999999);
            } while (static::where('public_id', $room->public_id)->exists());
        });
    }

    public function getRouteKeyName(): string { return 'public_id'; }

    public function host(): BelongsTo { return $this->belongsTo(User::class, 'host_user_id')->withTrashed(); }
    public function members(): HasMany { return $this->hasMany(RoomMember::class); }
    public function seats(): HasMany { return $this->hasMany(RoomSeat::class)->orderBy('position'); }
    public function messages(): HasMany { return $this->hasMany(RoomMessage::class); }
}
