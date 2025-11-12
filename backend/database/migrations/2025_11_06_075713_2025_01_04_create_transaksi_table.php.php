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
        Schema::create('transaksi', function (Blueprint $table) {
            $table->id();
            // user_id adalah foreign key ke tabel users
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            
            // ID unik yang bisa dilihat oleh user, misal: INV-2025-12345
            $table->string('order_id')->unique(); 

            // total_harga adalah total dari SEMUA item dalam pesanan
            $table->decimal('total_harga', 10, 2); 
            
            // Status PESANAN (logistik)
            $table->string('order_status')->default('pending'); // misal: pending, processing, shipped, completed, cancelled
            
            // --- Detail Pembayaran Sesuai Rencana Sistem ---
            // 'cod', 'gateway' (QRIS, Gopay), 'manual_transfer'
            $table->string('payment_method')->nullable(); 
            
            // Status PEMBAYARAN
            $table->string('payment_status')->default('pending'); // misal: pending, paid, failed
            
            // URL ke gambar bukti transfer jika payment_method = 'manual_transfer'
            $table->string('bukti_bayar_url')->nullable(); 
            
            // ID referensi dari payment gateway (jika pakai)
            $table->string('payment_gateway_ref')->nullable(); 

            // Alamat pengiriman, bisa dibuat lebih detail jika perlu
            $table->text('alamat_pengiriman')->nullable(); 
            
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
        Schema::dropIfExists('transaksi');
    }
};