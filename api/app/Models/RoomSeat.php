<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RoomSeat extends Model
{
    protected $guarded = [];
    protected function casts(): array { return ['is_locked' => 'boolean', 'mic_muted' => 'boolean']; }
    public function room(): BelongsTo { return $this->belongsTo(Room::class); }
    public function user(): BelongsTo { return $this->belongsTo(User::class)->withTrashed(); }
}
