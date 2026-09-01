<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('coin_wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->unsignedBigInteger('balance')->default(0);
            $table->unsignedBigInteger('version')->default(0);
            $table->timestamps();
        });
        Schema::create('coin_transactions', function (Blueprint $table) {
            $table->id();
            $table->uuid('reference')->unique();
            $table->foreignId('wallet_id')->constrained('coin_wallets')->cascadeOnDelete();
            $table->bigInteger('amount');
            $table->unsignedBigInteger('balance_after');
            $table->string('type', 40)->index();
            $table->string('description', 255);
            $table->json('metadata')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('created_at')->useCurrent();
        });
        $now = now();
        DB::table('users')->select('id')->orderBy('id')->chunk(500, function ($users) use ($now) {
            DB::table('coin_wallets')->insert($users->map(fn ($user) => [
                'user_id' => $user->id, 'balance' => 0, 'version' => 0, 'created_at' => $now, 'updated_at' => $now,
            ])->all());
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('coin_transactions');
        Schema::dropIfExists('coin_wallets');
    }
};
