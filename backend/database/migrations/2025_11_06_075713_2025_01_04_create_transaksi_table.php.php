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
        Schema::create('transaksi', function (Blueprint $table) {
            $table->id();
            $table->foreignId('iuran_id')->constrained('iuran')->onDelete('cascade');
            $table->foreignId('warga_id')->constrained('warga')->onDelete('cascade');
            $table->decimal('nominal_bayar', 15, 2);
            $table->enum('metode_pembayaran', ['Tunai', 'Transfer', 'QRIS'])->default('Transfer');
            $table->date('tanggal_bayar')->useCurrent();
            
            // Kolom untuk fitur CV (OCR Bukti Transfer)
            $table->string('bukti_transfer_path')->nullable();
            $table->enum('status_verifikasi', ['pending', 'verified', 'rejected'])->default('pending');
            $table->foreignId('verified_by_user_id')->nullable()->constrained('users')->onDelete('set null');

            // Kolom untuk fitur ML (Prediksi/Anomaly)
            $table->boolean('is_anomaly')->default(false)->comment('Hasil Anomaly Detection ML');
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transaksi');
    }
};