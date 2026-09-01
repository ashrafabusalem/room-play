<?php
namespace App\Http\Controllers\Api;
use App\Events\DirectMessageSent;
use App\Http\Controllers\Controller;
use App\Http\Resources\DirectMessageResource;
use App\Models\DirectConversation;
use App\Models\DirectMessage;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DirectMessageController extends Controller {
 public function index(Request $request): JsonResponse {
  $user=$request->user();
  $items=DirectConversation::where(fn($q)=>$q->where('user_one_id',$user->id)->orWhere('user_two_id',$user->id))->with(['userOne','userTwo'])->withCount(['messages as unread_count'=>fn($q)=>$q->where('sender_id','!=',$user->id)->whereNull('read_at')])->with(['messages'=>fn($q)=>$q->latest('id')->limit(1)])->latest('updated_at')->get();
  return response()->json(['conversations'=>$items->map(fn($c)=>$this->conversation($c,$user))->values()]);
 }
 public function search(Request $request): JsonResponse {
  $term=trim((string)$request->query('q')); abort_if(mb_strlen($term)<2,422,'Enter at least 2 characters.');
  $users=User::whereKeyNot($request->user()->id)->whereNull('blocked_at')->where(fn($q)=>$q->where('name','like',"%{$term}%")->orWhere('public_id',$term))->limit(20)->get();
  return response()->json(['users'=>$users->map(fn($u)=>['id'=>$u->public_id,'name'=>$u->name,'level'=>$u->level])->values()]);
 }
 public function store(Request $request): JsonResponse {
  $data=$request->validate(['user_id'=>['required','string','exists:users,public_id']]); $other=User::where('public_id',$data['user_id'])->firstOrFail(); abort_if($other->id===$request->user()->id,422,'You cannot message yourself.');
  [$one,$two]=collect([$request->user()->id,$other->id])->sort()->values();
  $c=DirectConversation::firstOrCreate(['user_one_id'=>$one,'user_two_id'=>$two]); $c->load(['userOne','userTwo','messages']);
  return response()->json(['conversation'=>$this->conversation($c,$request->user())],201);
 }
 public function show(Request $request,DirectConversation $conversation): JsonResponse {
  $this->authorizeUser($request,$conversation); DirectMessage::where('direct_conversation_id',$conversation->id)->where('sender_id','!=',$request->user()->id)->whereNull('read_at')->update(['read_at'=>now()]);
  $messages=DirectMessage::where('direct_conversation_id',$conversation->id)->with('sender')->latest('id')->limit(100)->get()->reverse()->values();
  return response()->json(['conversation'=>$this->conversation($conversation->load(['userOne','userTwo']),$request->user()),'messages'=>DirectMessageResource::collection($messages)->resolve()]);
 }
 public function send(Request $request,DirectConversation $conversation): JsonResponse {
  $this->authorizeUser($request,$conversation); $data=$request->validate(['text'=>['required','string','max:1000']]);
  $message=DB::transaction(function()use($request,$conversation,$data){$m=DirectMessage::create(['direct_conversation_id'=>$conversation->id,'sender_id'=>$request->user()->id,'body'=>trim($data['text'])]);$conversation->touch();return $m->load('sender');});
  $recipient=$conversation->other($request->user())->public_id; broadcast(new DirectMessageSent($message,$recipient))->toOthers();
  return response()->json(['message'=>(new DirectMessageResource($message))->resolve()],201);
 }
 private function authorizeUser(Request $r,DirectConversation $c): void { abort_unless($c->includes($r->user()),403); }
 private function conversation(DirectConversation $c,User $u): array {$other=$c->other($u);$last=$c->messages->first();return ['id'=>(string)$c->id,'user'=>['id'=>$other->public_id,'name'=>$other->name,'level'=>$other->level],'last_message'=>$last?['text'=>$last->body,'created_at'=>$last->created_at?->toISOString()]:null,'unread_count'=>(int)($c->unread_count??0)];}
}
