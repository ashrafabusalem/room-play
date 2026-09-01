<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $now = now();
        DB::table('game_prompts')->insert(array_map(fn ($word) => [
            'game' => 'spy', 'type' => 'word', 'text_en' => $word[0], 'text_ar' => $word[1],
            'minimum_age' => 13, 'is_active' => true, 'created_at' => $now, 'updated_at' => $now,
        ], [
            ['Airport', 'مطار'], ['Chocolate', 'شوكولاتة'], ['Hospital', 'مستشفى'],
            ['Football', 'كرة القدم'], ['Library', 'مكتبة'], ['Wedding', 'حفل زفاف'],
            ['Restaurant', 'مطعم'], ['Beach', 'شاطئ'], ['School', 'مدرسة'], ['Cinema', 'سينما'],
        ]));
    }

    public function down(): void
    {
        DB::table('game_prompts')->where('game', 'spy')->delete();
    }
};
