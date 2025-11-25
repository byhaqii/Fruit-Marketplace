<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('transaksi', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade'); // Pembeli
            
            // Kolom Baru: Identifikasi Penjual (Agar transaksi terpisah per penjual)
            // Opsional: Jika ingin strict 1 transaksi = 1 penjual di level database
            // $table->foreignId('seller_id')->nullable()->constrained('users'); 

            $table->string('order_id')->unique(); 
            $table->decimal('total_harga', 15, 2); // Harga Barang + Ongkir
            
            // Logistik & Pengiriman (YANG SEBELUMNYA KURANG)
            $table->decimal('ongkos_kirim', 10, 2)->default(0);
            $table->string('kurir')->nullable(); // misal: JNE, J&T
            $table->string('layanan_kurir')->nullable(); // misal: REG, YES
            $table->string('nomor_resi')->nullable(); // Diisi penjual saat dikirim
            
            $table->enum('order_status', [
                'menunggu konfirmasi', 'Diproses', 'Dikirim', 
                'Tiba di tujuan', 'Selesai', 'Dibatalkan'
            ])->default('menunggu konfirmasi');
            
            $table->string('payment_method')->nullable(); 
            $table->string('payment_status')->default('pending');
            $table->string('bukti_bayar_url')->nullable(); 
            $table->text('alamat_pengiriman')->nullable(); 
            
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('transaksi');
    }
};