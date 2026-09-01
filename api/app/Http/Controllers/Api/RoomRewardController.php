<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;use App\Models\{Room,RoomRewardClaim};use App\Services\CoinLedger;use Illuminate\Http\{JsonResponse,Request};use Illuminate\Support\Facades\DB;use Illuminate\Validation\ValidationException;
class RoomRewardController extends Controller{
 private const REWARD=5;private const COOLDOWN_MINUTES=30;
 public function show(Request $r,Room $room):JsonResponse{$this->member($r,$room);$claim=RoomRewardClaim::where(['room_id'=>$room->id,'user_id'=>$r->user()->id])->first();return response()->json($this->payload($claim));}
 public function claim(Request $r,Room $room,CoinLedger $ledger):JsonResponse{$this->member($r,$room);$claim=DB::transaction(function()use($r,$room,$ledger){RoomRewardClaim::firstOrCreate(['room_id'=>$room->id,'user_id'=>$r->user()->id]);$claim=RoomRewardClaim::where(['room_id'=>$room->id,'user_id'=>$r->user()->id])->lockForUpdate()->firstOrFail();if($claim->next_claim_at?->isFuture())throw ValidationException::withMessages(['reward'=>'The room reward is not ready yet.']);$ledger->post($r->user(),self::REWARD,'room_reward','Room treasure reward',null,['room_id'=>$room->public_id]);$claim->update(['next_claim_at'=>now()->addMinutes(self::COOLDOWN_MINUTES),'claims_count'=>$claim->claims_count+1]);return $claim;});return response()->json([...$this->payload($claim),'balance'=>$r->user()->wallet()->value('balance')]);}
 private function member(Request $r,Room $room):void{abort_unless($room->members()->where('user_id',$r->user()->id)->exists(),403,'Join the room first.');}
 private function payload(?RoomRewardClaim $claim):array{$next=$claim?->next_claim_at;return ['reward'=>self::REWARD,'available'=>$next===null||$next->isPast(),'next_claim_at'=>$next?->toISOString(),'server_time'=>now()->toISOString()];}
}
