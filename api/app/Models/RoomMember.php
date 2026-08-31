<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RoomMember extends Model
{
    public $timestamps = false;
    protected $guarded = [];
    protected function casts(): array { return ['joined_at' => 'datetime', 'last_seen_at' => 'datetime']; }
    public function room(): BelongsTo { return $this->belongsTo(Room::class); }
    public function user(): BelongsTo { return $this->belongsTo(User::class)->withTrashed(); }
}
