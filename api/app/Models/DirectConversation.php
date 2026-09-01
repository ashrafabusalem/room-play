<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
class DirectConversation extends Model {
 protected $guarded=[];
 public function userOne(): BelongsTo { return $this->belongsTo(User::class,'user_one_id')->withTrashed(); }
 public function userTwo(): BelongsTo { return $this->belongsTo(User::class,'user_two_id')->withTrashed(); }
 public function messages(): HasMany { return $this->hasMany(DirectMessage::class); }
 public function other(User $user): User { return $this->user_one_id === $user->id ? $this->userTwo : $this->userOne; }
 public function includes(User $user): bool { return in_array($user->id,[$this->user_one_id,$this->user_two_id],true); }
}
