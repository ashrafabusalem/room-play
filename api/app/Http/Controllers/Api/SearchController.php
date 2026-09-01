<?php
namespace App\Http\Controllers\Api;
use App\Http\Resources\RoomResource;use App\Models\{Room,User};use Illuminate\Http\{JsonResponse,Request};
class SearchController{
 public function __invoke(Request $request):JsonResponse{$term=trim((string)$request->query('q'));abort_if(mb_strlen($term)<2,422,'Enter at least 2 characters.');$me=$request->user();$users=User::whereKeyNot($me->id)->whereNull('blocked_at')->where(fn($q)=>$q->where('name','like',"%{$term}%")->orWhere('public_id',$term))->whereNotExists(fn($q)=>$q->selectRaw('1')->from('user_blocks')->where(fn($b)=>$b->whereColumn('blocker_id','users.id')->where('blocked_id',$me->id)->orWhere(fn($x)=>$x->where('blocker_id',$me->id)->whereColumn('blocked_id','users.id'))))->limit(20)->get();$rooms=Room::whereNull('closed_at')->where(fn($q)=>$q->where('name','like',"%{$term}%")->orWhere('public_id',$term))->with(['host','members.user','seats.user'])->limit(20)->get();return response()->json(['users'=>$users->map(fn($u)=>['id'=>$u->public_id,'name'=>$u->name,'level'=>$u->level,'avatar_url'=>$u->avatarUrl()])->values(),'rooms'=>RoomResource::collection($rooms)->resolve()]);}
}
