<?php
namespace App\Models;use Illuminate\Database\Eloquent\Model;
class RoomRewardClaim extends Model{protected $guarded=[];protected function casts():array{return ['next_claim_at'=>'datetime','claims_count'=>'integer'];}}
