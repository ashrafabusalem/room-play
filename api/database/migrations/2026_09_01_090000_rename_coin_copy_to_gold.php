<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        DB::table('banners')
            ->where('subtitle_en', "Win coins in Ludo and UNO\nall weekend long.")
            ->update([
                'subtitle_en' => "Win Gold in Ludo and UNO\nall weekend long.",
                'subtitle_ar' => "اربح الذهب في لودو ويونو\nطوال عطلة الأسبوع.",
            ]);
    }

    public function down(): void
    {
        DB::table('banners')
            ->where('subtitle_en', "Win Gold in Ludo and UNO\nall weekend long.")
            ->update([
                'subtitle_en' => "Win coins in Ludo and UNO\nall weekend long.",
                'subtitle_ar' => "اربح العملات في لودو ويونو\nطوال عطلة الأسبوع.",
            ]);
    }
};
