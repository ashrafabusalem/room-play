<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GameRequest extends Model
{
    protected $guarded = [];

    protected function casts(): array
    {
        return ['responded_at' => 'datetime'];
    }

    public function room() { return $this->belongsTo(Room::class); }
    public function requester() { return $this->belongsTo(User::class, 'requester_id'); }
}
