<?php
namespace App\Http\Controllers\Admin;
use App\Http\Controllers\Controller;use App\Models\{AdminAudit,Gift,RoomGift};use Illuminate\Http\{RedirectResponse,Request};use Illuminate\View\View;
class GiftController extends Controller{
 public function index():View{return view('admin.gifts.index',['gifts'=>Gift::withCount('roomGifts')->withSum('roomGifts','price')->orderBy('sort_order')->get(),'totalSends'=>RoomGift::count(),'totalGold'=>(int)RoomGift::sum('price'),'weekSends'=>RoomGift::where('created_at','>=',now()->subDays(7))->count()]);}
 public function create():View{return view('admin.gifts.form',['gift'=>new Gift]);}
 public function store(Request $r):RedirectResponse{$gift=Gift::create($this->data($r));$this->audit($r,'gift.created',$gift);return redirect()->route('admin.gifts.edit',$gift)->with('success','Gift created.');}
 public function edit(Gift $gift):View{return view('admin.gifts.form',compact('gift'));}
 public function update(Request $r,Gift $gift):RedirectResponse{$gift->update($this->data($r));$this->audit($r,'gift.updated',$gift);return back()->with('success','Gift updated.');}
 public function destroy(Request $r,Gift $gift):RedirectResponse{if($gift->roomGifts()->exists()){$gift->update(['is_active'=>false]);return back()->with('success','Used gift hidden instead of deleted.');}$this->audit($r,'gift.deleted',$gift);$gift->delete();return redirect()->route('admin.gifts.index')->with('success','Gift deleted.');}
 private function data(Request $r):array{$d=$r->validate(['name_en'=>['required','string','max:120'],'name_ar'=>['required','string','max:120'],'emoji'=>['required','string','max:20'],'price'=>['required','integer','min:1','max:1000000000'],'sort_order'=>['required','integer','min:0']]);$d['is_active']=$r->boolean('is_active');return $d;}
 private function audit(Request $r,string $action,Gift $gift):void{AdminAudit::create(['admin_id'=>$r->user()->id,'action'=>$action,'target_type'=>Gift::class,'target_id'=>$gift->id,'ip_address'=>$r->ip(),'user_agent'=>$r->userAgent()]);}
}
