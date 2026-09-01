<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Gift extends Model { protected $guarded=[]; protected function casts():array{return ['price'=>'integer','is_active'=>'boolean'];} public function roomGifts(){return $this->hasMany(RoomGift::class);} }
