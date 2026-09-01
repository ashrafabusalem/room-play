<?php
use Illuminate\Database\Migrations\Migration;use Illuminate\Database\Schema\Blueprint;use Illuminate\Support\Facades\Schema;
return new class extends Migration{public function up():void{Schema::table('app_settings',function(Blueprint $t){$t->unsignedInteger('room_reward_gold')->default(5);$t->unsignedInteger('room_reward_cooldown_minutes')->default(30);});}public function down():void{Schema::table('app_settings',fn(Blueprint $t)=>$t->dropColumn(['room_reward_gold','room_reward_cooldown_minutes']));}};
