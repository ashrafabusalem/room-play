<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('game_prompts', function (Blueprint $table) {
            $table->id();
            $table->string('game', 40)->index();
            $table->string('type', 30)->index();
            $table->text('text_en');
            $table->text('text_ar');
            $table->unsignedTinyInteger('minimum_age')->default(13);
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();
        });
        Schema::create('game_sessions', function (Blueprint $table) {
            $table->id();
            $table->uuid('public_id')->unique();
            $table->foreignId('room_id')->constrained()->cascadeOnDelete();
            $table->string('game', 40)->index();
            $table->string('status', 20)->default('lobby')->index();
            $table->foreignId('host_user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('current_player_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('current_prompt_id')->nullable()->constrained('game_prompts')->nullOnDelete();
            $table->unsignedInteger('turn_number')->default(0);
            $table->timestamp('started_at')->nullable();
            $table->timestamp('finished_at')->nullable();
            $table->timestamps();
        });
        Schema::create('game_session_players', function (Blueprint $table) {
            $table->id();
            $table->foreignId('game_session_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('position');
            $table->timestamps();
            $table->unique(['game_session_id', 'user_id']);
            $table->unique(['game_session_id', 'position']);
        });

        $now = now();
        DB::table('game_prompts')->insert([
            ['game'=>'truth_or_dare','type'=>'truth','text_en'=>'What is something you have always wanted to learn?','text_ar'=>'ما الشيء الذي طالما أردت أن تتعلمه؟','minimum_age'=>13,'is_active'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['game'=>'truth_or_dare','type'=>'truth','text_en'=>'What is your funniest childhood memory?','text_ar'=>'ما أطرف ذكرى لديك من الطفولة؟','minimum_age'=>13,'is_active'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['game'=>'truth_or_dare','type'=>'truth','text_en'=>'Who in this room would survive longest on a deserted island?','text_ar'=>'من في هذه الغرفة سيصمد أطول مدة في جزيرة مهجورة؟','minimum_age'=>13,'is_active'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['game'=>'truth_or_dare','type'=>'truth','text_en'=>'What is the best advice you have ever received?','text_ar'=>'ما أفضل نصيحة تلقيتها في حياتك؟','minimum_age'=>13,'is_active'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['game'=>'truth_or_dare','type'=>'dare','text_en'=>'Speak in a movie-trailer voice until your next turn.','text_ar'=>'تحدث بصوت إعلان فيلم حتى دورك القادم.','minimum_age'=>13,'is_active'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['game'=>'truth_or_dare','type'=>'dare','text_en'=>'Do your best animal impression for ten seconds.','text_ar'=>'قلّد حيواناً بأفضل طريقة لمدة عشر ثوانٍ.','minimum_age'=>13,'is_active'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['game'=>'truth_or_dare','type'=>'dare','text_en'=>'Make up a short song using another player’s name.','text_ar'=>'ألّف أغنية قصيرة تتضمن اسم لاعب آخر.','minimum_age'=>13,'is_active'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['game'=>'truth_or_dare','type'=>'dare','text_en'=>'Give every player a sincere compliment.','text_ar'=>'قدم لكل لاعب مجاملة صادقة.','minimum_age'=>13,'is_active'=>true,'created_at'=>$now,'updated_at'=>$now],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('game_session_players');
        Schema::dropIfExists('game_sessions');
        Schema::dropIfExists('game_prompts');
    }
};
