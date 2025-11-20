<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('produk_id')->constrained('produk')->onDelete('cascade');
            
            // --- PERUBAHAN DI SINI ---
            // Mengganti warga_id menjadi user_id
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade')->comment('Pemberi review');
            // --- AKHIR PERUBAHAN ---

            $table->unsignedTinyInteger('rating')->comment('Nilai 1 sampai 5');
            $table->text('komentar')->nullable();
            $table->timestamps();
            
            // --- PERUBAHAN DI SINI ---
            // Menyesuaikan unique constraint
            $table->unique(['produk_id', 'user_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};