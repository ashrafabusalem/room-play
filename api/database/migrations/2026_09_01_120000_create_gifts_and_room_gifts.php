<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('gifts', function (Blueprint $table) {
            $table->id(); $table->string('name_en'); $table->string('name_ar');
            $table->string('emoji', 20)->default('🎁'); $table->unsignedBigInteger('price');
            $table->boolean('is_active')->default(true); $table->unsignedInteger('sort_order')->default(0); $table->timestamps();
        });
        Schema::create('room_gifts', function (Blueprint $table) {
            $table->id(); $table->foreignId('room_id')->constrained()->cascadeOnDelete();
            $table->foreignId('gift_id')->constrained()->restrictOnDelete();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('recipient_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedBigInteger('price'); $table->timestamp('created_at')->useCurrent();
        });
        DB::table('gifts')->insert([
            ['name_en'=>'Rose','name_ar'=>'وردة','emoji'=>'🌹','price'=>10,'sort_order'=>10,'created_at'=>now(),'updated_at'=>now()],
            ['name_en'=>'Crown','name_ar'=>'تاج','emoji'=>'👑','price'=>100,'sort_order'=>20,'created_at'=>now(),'updated_at'=>now()],
            ['name_en'=>'Sports car','name_ar'=>'سيارة رياضية','emoji'=>'🏎️','price'=>1000,'sort_order'=>30,'created_at'=>now(),'updated_at'=>now()],
        ]);
    }
    public function down(): void { Schema::dropIfExists('room_gifts'); Schema::dropIfExists('gifts'); }
};
