<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up(): void {
  Schema::create('direct_conversations', function (Blueprint $t) { $t->id(); $t->foreignId('user_one_id')->constrained('users')->cascadeOnDelete(); $t->foreignId('user_two_id')->constrained('users')->cascadeOnDelete(); $t->timestamps(); $t->unique(['user_one_id','user_two_id']); });
  Schema::create('direct_messages', function (Blueprint $t) { $t->id(); $t->foreignId('direct_conversation_id')->constrained()->cascadeOnDelete(); $t->foreignId('sender_id')->constrained('users')->cascadeOnDelete(); $t->string('body',1000); $t->timestamp('read_at')->nullable(); $t->timestamps(); $t->index(['direct_conversation_id','id']); });
 }
 public function down(): void { Schema::dropIfExists('direct_messages'); Schema::dropIfExists('direct_conversations'); }
};
