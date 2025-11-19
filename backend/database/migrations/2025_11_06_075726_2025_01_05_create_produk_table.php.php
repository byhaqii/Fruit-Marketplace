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
        Schema::create('produk', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade')->comment('ID User Penjual');
            $table->string('nama_produk');
            $table->text('deskripsi')->nullable();
            $table->decimal('harga', 15, 2);
            $table->integer('stok')->default(0);
            $table->string('gambar_url')->nullable();
            $table->string('kategori')->nullable()->comment('Hasil Image Classification CV');
            $table->enum('status_jual', [
                'Aktif',
                'Nonaktif',
                'Dalam pengecekan',
                'Gagal',
                'Diblokir',
                'Draft',
                'Habis' // Opsional: Bisa otomatis jika stok 0
            ])->default('Draft');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('produk');
    }
};
