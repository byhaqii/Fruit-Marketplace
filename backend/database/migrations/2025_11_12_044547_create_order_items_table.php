<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        // Tabel ini akan menghubungkan 'transaksi' (order) dengan 'produk'
        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            
            // Foreign key ke tabel transaksi
            $table->foreignId('transaksi_id')->constrained('transaksi')->onDelete('cascade');
            
            // Foreign key ke tabel produk
            $table->foreignId('produk_id')->constrained('produk')->onDelete('cascade');
            
            // Jumlah produk yang dibeli
            $table->integer('jumlah');
            
            // Menyimpan harga produk PADA SAAT dibeli (penting jika harga produk berubah)
            $table->decimal('harga_saat_beli', 10, 2); 
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('order_items');
    }
};