<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // The short numeric id people share with each other and see in a
            // room header. Deliberately separate from the primary key: this one
            // is public, guessable, and may need reissuing.
            $table->string('public_id', 12)->nullable()->unique()->after('id');

            $table->unsignedInteger('level')->default(1)->after('password');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique(['public_id']);
            $table->dropColumn(['public_id', 'level']);
        });
    }
};
