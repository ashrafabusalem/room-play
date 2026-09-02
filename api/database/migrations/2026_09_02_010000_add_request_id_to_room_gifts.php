<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('room_gifts', function (Blueprint $table) {
            $table->string('request_id', 64)->nullable()->after('recipient_id');
            $table->unique(['sender_id', 'request_id']);
        });
    }

    public function down(): void
    {
        Schema::table('room_gifts', function (Blueprint $table) {
            $table->dropUnique(['sender_id', 'request_id']);
            $table->dropColumn('request_id');
        });
    }
};
