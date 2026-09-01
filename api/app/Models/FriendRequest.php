<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FriendRequest extends Model
{
    protected $guarded = [];
    protected function casts(): array { return ['responded_at' => 'datetime']; }
    public function requester() { return $this->belongsTo(User::class, 'requester_id'); }
    public function addressee() { return $this->belongsTo(User::class, 'addressee_id'); }
}
