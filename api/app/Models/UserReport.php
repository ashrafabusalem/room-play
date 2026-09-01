<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserReport extends Model
{
    protected $guarded = [];

    protected function casts(): array
    {
        return ['reviewed_at' => 'datetime'];
    }

    public function reporter() { return $this->belongsTo(User::class, 'reporter_id'); }
    public function reported() { return $this->belongsTo(User::class, 'reported_id'); }
    public function reviewer() { return $this->belongsTo(User::class, 'reviewed_by'); }
}
