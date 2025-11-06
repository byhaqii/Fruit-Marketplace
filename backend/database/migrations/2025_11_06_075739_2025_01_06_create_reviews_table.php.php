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
            $table->foreignId('warga_id')->constrained('warga')->onDelete('cascade')->comment('Pemberi review');
            $table->unsignedTinyInteger('rating')->comment('Nilai 1 sampai 5');
            $table->text('komentar')->nullable();
            $table->timestamps();
            
            // Memastikan satu warga hanya bisa review satu produk sekali
            $table->unique(['produk_id', 'warga_id']);
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