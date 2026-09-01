<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;use App\Models\{Gift,Room,User};use App\Services\GiftService;use Illuminate\Http\{JsonResponse,Request};
class GiftController extends Controller{
 public function index(Request $r):JsonResponse{$lang=$r->getPreferredLanguage(['ar','en'])==='ar'?'ar':'en';return response()->json(['gifts'=>Gift::where('is_active',true)->orderBy('sort_order')->get()->map(fn($g)=>['id'=>$g->id,'name'=>$g->{'name_'.$lang},'emoji'=>$g->emoji,'price'=>$g->price])]);}
 public function send(Request $r,Room $room,Gift $gift,GiftService $service):JsonResponse{$data=$r->validate(['recipient_id'=>['required','string']]);$recipient=User::where('public_id',$data['recipient_id'])->firstOrFail();$sent=$service->send($room,$gift,$r->user(),$recipient);return response()->json(['gift'=>['id'=>$sent->id,'name'=>$gift->name_en,'emoji'=>$gift->emoji,'price'=>$sent->price],'balance'=>$r->user()->wallet()->value('balance')],201);}
}
