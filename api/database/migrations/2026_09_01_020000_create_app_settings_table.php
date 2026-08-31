<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('app_settings', function (Blueprint $table) {
            $table->id();
            $table->boolean('registration_enabled')->default(true);
            $table->boolean('maintenance_enabled')->default(false);
            $table->text('maintenance_message_en')->nullable();
            $table->text('maintenance_message_ar')->nullable();
            $table->string('support_email')->nullable();
            $table->string('support_url')->nullable();
            $table->string('terms_url')->nullable();
            $table->string('privacy_url')->nullable();
            $table->string('minimum_android_version', 30)->nullable();
            $table->string('minimum_ios_version', 30)->nullable();
            $table->boolean('force_update')->default(false);
            $table->timestamps();
        });

        DB::table('app_settings')->insert([
            'registration_enabled' => true,
            'maintenance_enabled' => false,
            'support_email' => 'info@sitenhost.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('app_settings');
    }
};
