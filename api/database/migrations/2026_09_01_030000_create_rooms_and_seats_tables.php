<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rooms', function (Blueprint $table) {
            $table->id();
            $table->string('public_id', 12)->unique();
            $table->foreignId('host_user_id')->constrained('users')->restrictOnDelete();
            $table->string('name', 80);
            $table->string('language', 8)->default('EN')->index();
            $table->string('tag', 30)->default('chatting')->index();
            $table->unsignedTinyInteger('seat_count')->default(9);
            $table->unsignedInteger('max_members')->default(100);
            $table->boolean('is_featured')->default(false)->index();
            $table->boolean('is_locked')->default(false);
            $table->timestamp('closed_at')->nullable()->index();
            $table->timestamps();
        });

        Schema::create('room_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('room_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('role', 20)->default('member');
            $table->timestamp('joined_at')->useCurrent();
            $table->timestamp('last_seen_at')->useCurrent();
            $table->unique(['room_id', 'user_id']);
        });

        Schema::create('room_seats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('room_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('position');
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->boolean('is_locked')->default(false);
            $table->boolean('mic_muted')->default(true);
            $table->timestamps();
            $table->unique(['room_id', 'position']);
            $table->unique(['room_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('room_seats');
        Schema::dropIfExists('room_members');
        Schema::dropIfExists('rooms');
    }
};
