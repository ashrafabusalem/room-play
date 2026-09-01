<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class GameSessionPlayer extends Model { protected $guarded=[]; public function user(){return $this->belongsTo(User::class);} public function session(){return $this->belongsTo(GameSession::class,'game_session_id');} }
