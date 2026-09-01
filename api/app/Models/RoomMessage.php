<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RoomMessage extends Model
{
    protected $guarded = [];
    public function room(): BelongsTo { return $this->belongsTo(Room::class); }
    public function user(): BelongsTo { return $this->belongsTo(User::class)->withTrashed(); }
}
