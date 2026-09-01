<?php
use Illuminate\Database\Migrations\Migration;use Illuminate\Database\Schema\Blueprint;use Illuminate\Support\Facades\Schema;
return new class extends Migration{public function up():void{Schema::create('room_reward_claims',function(Blueprint $t){$t->id();$t->foreignId('room_id')->constrained()->cascadeOnDelete();$t->foreignId('user_id')->constrained()->cascadeOnDelete();$t->timestamp('next_claim_at')->nullable();$t->unsignedInteger('claims_count')->default(0);$t->timestamps();$t->unique(['room_id','user_id']);});}public function down():void{Schema::dropIfExists('room_reward_claims');}};
