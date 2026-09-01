<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RoomInvitation extends Model
{
    protected $guarded = [];
    protected function casts(): array { return ['responded_at' => 'datetime']; }
    public function room() { return $this->belongsTo(Room::class); }
    public function inviter() { return $this->belongsTo(User::class, 'inviter_id'); }
    public function invitee() { return $this->belongsTo(User::class, 'invitee_id'); }
}
