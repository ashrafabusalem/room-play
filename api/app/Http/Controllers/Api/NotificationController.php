<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
class NotificationController extends Controller {
 public function index(Request $r):JsonResponse{$q=AppNotification::where('user_id',$r->user()->id);$items=(clone $q)->with('actor')->latest()->paginate(40);return response()->json(['unread_count'=>(clone $q)->whereNull('read_at')->count(),'notifications'=>$items->getCollection()->map(fn($n)=>['id'=>(string)$n->id,'type'=>$n->type,'data'=>$n->data??[],'read_at'=>$n->read_at?->toISOString(),'created_at'=>$n->created_at->toISOString(),'actor'=>$n->actor ? ['id'=>$n->actor->public_id,'name'=>$n->actor->name,'avatar_url'=>$n->actor->avatarUrl()] : null])->values()]);}
 public function read(Request $r,AppNotification $notification):JsonResponse{abort_unless($notification->user_id===$r->user()->id,403);$notification->update(['read_at'=>$notification->read_at??now()]);return response()->json(['message'=>'Notification read.']);}
 public function readAll(Request $r):JsonResponse{AppNotification::where('user_id',$r->user()->id)->whereNull('read_at')->update(['read_at'=>now()]);return response()->json(['message'=>'Notifications read.']);}
}
