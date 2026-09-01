<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class RoomGift extends Model { public const UPDATED_AT=null; protected $guarded=[]; public function room(){return $this->belongsTo(Room::class);} public function gift(){return $this->belongsTo(Gift::class);} public function sender(){return $this->belongsTo(User::class);} public function recipient(){return $this->belongsTo(User::class);} }
