<?php
namespace App\Http\Controllers\Api;
use App\Models\{RoomGift,User};use Illuminate\Http\{JsonResponse,Request};use Illuminate\Support\Facades\DB;
class RankingController{
 public function __invoke(Request $request):JsonResponse{$period=$request->validate(['period'=>['nullable','in:weekly,all']])['period']??'weekly';$since=$period==='weekly'?now()->subDays(7):null;return response()->json(['period'=>$period,'sent'=>$this->ranking('sender_id',$since),'received'=>$this->ranking('recipient_id',$since)]);}
 private function ranking(string $column,$since):array{$query=RoomGift::query()->select($column,DB::raw('SUM(price) as total'))->groupBy($column)->orderByDesc('total')->limit(50);if($since)$query->where('created_at','>=',$since);$rows=$query->get();$users=User::withTrashed()->whereIn('id',$rows->pluck($column))->get()->keyBy('id');return $rows->values()->map(function($row,$index)use($column,$users){$user=$users[$row->{$column}]??null;return ['rank'=>$index+1,'user'=>['id'=>$user?->public_id,'name'=>$user?->name??'Deleted user','avatar_url'=>$user?->avatarUrl()],'gold'=>(int)$row->total];})->all();}
}
