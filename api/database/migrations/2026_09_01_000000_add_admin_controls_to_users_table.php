<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->boolean('is_admin')->default(false)->after('level')->index();
            $table->timestamp('blocked_at')->nullable()->after('is_admin')->index();
            $table->boolean('must_change_password')->default(false)->after('blocked_at');
            $table->softDeletes();
        });

        Schema::create('admin_audits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('admin_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('action', 80)->index();
            $table->string('target_type', 80)->nullable();
            $table->unsignedBigInteger('target_id')->nullable();
            $table->json('metadata')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamps();

            $table->index(['target_type', 'target_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('admin_audits');

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['is_admin', 'blocked_at', 'must_change_password', 'deleted_at']);
        });
    }
};
