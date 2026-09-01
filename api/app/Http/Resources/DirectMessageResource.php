<?php
namespace App\Http\Resources;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
class DirectMessageResource extends JsonResource {
 public function toArray(Request $request): array { return ['id'=>(string)$this->id,'text'=>$this->body,'created_at'=>$this->created_at?->toISOString(),'read_at'=>$this->read_at?->toISOString(),'sender'=>['id'=>$this->sender->public_id,'name'=>$this->sender->name,'level'=>$this->sender->level]]; }
}
