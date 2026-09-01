<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;
class GameSession extends Model {
 protected $guarded=[];
 protected function casts():array{return ['turn_number'=>'integer','started_at'=>'datetime','finished_at'=>'datetime'];}
 protected static function booted():void{static::creating(fn($m)=>$m->public_id??=(string)Str::uuid());}
 public function getRouteKeyName():string{return 'public_id';}
 public function room(){return $this->belongsTo(Room::class);}
 public function host(){return $this->belongsTo(User::class,'host_user_id');}
 public function currentPlayer(){return $this->belongsTo(User::class,'current_player_id');}
 public function currentPrompt(){return $this->belongsTo(GamePrompt::class,'current_prompt_id');}
 public function players(){return $this->hasMany(GameSessionPlayer::class)->orderBy('position');}
}
