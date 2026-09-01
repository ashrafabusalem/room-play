<?php
namespace App\Services;
use App\Models\AppNotification;
use App\Models\User;
class InAppNotifier {
 public function send(User $user,string $type,?User $actor=null,array $data=[]):AppNotification{return AppNotification::create(['user_id'=>$user->id,'actor_id'=>$actor?->id,'type'=>$type,'data'=>$data?:null]);}
}
