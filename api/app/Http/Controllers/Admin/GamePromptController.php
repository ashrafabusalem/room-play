<?php
namespace App\Http\Controllers\Admin;
use App\Http\Controllers\Controller;
use App\Models\AdminAudit;
use App\Models\GamePrompt;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;
class GamePromptController extends Controller {
 public function index(Request $r):View{$q=GamePrompt::where('game','truth_or_dare');if($r->filled('type'))$q->where('type',$r->query('type'));return view('admin.game-prompts.index',['prompts'=>$q->latest()->paginate(30),'type'=>(string)$r->query('type')]);}
 public function create():View{return view('admin.game-prompts.form',['prompt'=>new GamePrompt]);}
 public function store(Request $r):RedirectResponse{$p=GamePrompt::create(['game'=>'truth_or_dare',...$this->data($r)]);$this->audit($r,'game_prompt.created',$p);return redirect()->route('admin.game-prompts.edit',$p)->with('success','Prompt created.');}
 public function edit(GamePrompt $gamePrompt):View{return view('admin.game-prompts.form',['prompt'=>$gamePrompt]);}
 public function update(Request $r,GamePrompt $gamePrompt):RedirectResponse{$gamePrompt->update($this->data($r));$this->audit($r,'game_prompt.updated',$gamePrompt);return back()->with('success','Prompt updated.');}
 public function destroy(Request $r,GamePrompt $gamePrompt):RedirectResponse{$this->audit($r,'game_prompt.deleted',$gamePrompt);$gamePrompt->delete();return redirect()->route('admin.game-prompts.index')->with('success','Prompt deleted.');}
 private function data(Request $r):array{$d=$r->validate(['type'=>['required',Rule::in(['truth','dare'])],'text_en'=>['required','string','max:1000'],'text_ar'=>['required','string','max:1000'],'minimum_age'=>['required','integer','min:13','max:18'],'is_active'=>['nullable','boolean']]);$d['is_active']=$r->boolean('is_active');return $d;}
 private function audit(Request $r,string $action,GamePrompt $p):void{AdminAudit::create(['admin_id'=>$r->user()->id,'action'=>$action,'target_type'=>GamePrompt::class,'target_id'=>$p->id,'ip_address'=>$r->ip(),'user_agent'=>$r->userAgent()]);}
}
