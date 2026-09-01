<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class AppNotification extends Model { protected $guarded=[]; protected function casts():array{return ['data'=>'array','read_at'=>'datetime'];} public function user(){return $this->belongsTo(User::class);} public function actor(){return $this->belongsTo(User::class,'actor_id')->withTrashed();} }
