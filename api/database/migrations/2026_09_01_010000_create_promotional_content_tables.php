<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('banners', function (Blueprint $table) {
            $table->id();
            $table->string('title_en');
            $table->string('title_ar');
            $table->text('subtitle_en')->nullable();
            $table->text('subtitle_ar')->nullable();
            $table->string('cta_en')->nullable();
            $table->string('cta_ar')->nullable();
            $table->string('image_path')->nullable();
            $table->string('action_type', 30)->default('none');
            $table->string('action_value')->nullable();
            $table->unsignedInteger('sort_order')->default(0)->index();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamp('starts_at')->nullable()->index();
            $table->timestamp('ends_at')->nullable()->index();
            $table->timestamps();
        });

        Schema::create('offers', function (Blueprint $table) {
            $table->id();
            $table->string('title_en');
            $table->string('title_ar');
            $table->text('description_en')->nullable();
            $table->text('description_ar')->nullable();
            $table->string('badge_en')->nullable();
            $table->string('badge_ar')->nullable();
            $table->string('image_path')->nullable();
            $table->decimal('price', 12, 2)->nullable();
            $table->decimal('original_price', 12, 2)->nullable();
            $table->string('currency', 8)->default('USD');
            $table->unsignedBigInteger('reward_coins')->default(0);
            $table->string('action_value')->nullable();
            $table->unsignedInteger('sort_order')->default(0)->index();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamp('starts_at')->nullable()->index();
            $table->timestamp('ends_at')->nullable()->index();
            $table->timestamps();
        });

        DB::table('banners')->insert([
            ['title_en' => "Play Games\nMake Friends", 'title_ar' => "العب الألعاب\nكوّن صداقات", 'subtitle_en' => "Millions of players are\nwaiting for you!", 'subtitle_ar' => "ملايين اللاعبين\nبانتظارك!", 'cta_en' => 'Start Now', 'cta_ar' => 'ابدأ الآن', 'action_type' => 'games', 'sort_order' => 10, 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['title_en' => "Weekend\nTournament", 'title_ar' => "بطولة\nنهاية الأسبوع", 'subtitle_en' => "Win coins in Ludo and UNO\nall weekend long.", 'subtitle_ar' => "اربح العملات في لودو ويونو\nطوال عطلة الأسبوع.", 'cta_en' => 'Join', 'cta_ar' => 'انضم', 'action_type' => 'games', 'sort_order' => 20, 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['title_en' => "Host a Room\nEarn Rewards", 'title_ar' => "استضف غرفة\nواربح المكافآت", 'subtitle_en' => "Open a voice room and grow\nyour audience.", 'subtitle_ar' => "افتح غرفة صوتية\nووسّع جمهورك.", 'cta_en' => 'Create Room', 'cta_ar' => 'إنشاء غرفة', 'action_type' => 'rooms', 'sort_order' => 30, 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('offers');
        Schema::dropIfExists('banners');
    }
};
