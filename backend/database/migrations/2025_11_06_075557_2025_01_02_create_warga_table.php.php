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
        Schema::create('warga', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->unique()->constrained('users')->onDelete('cascade');
            $table->string('nik', 16)->unique()->nullable()->comment('Dari OCR KTP'); // Dibuat nullable
            $table->string('nama');
            $table->string('tempat_lahir')->nullable();
            $table->date('tanggal_lahir')->nullable();
            $table->enum('jenis_kelamin', ['Laki-laki', 'Perempuan'])->nullable(); // Dibuat nullable
            $table->text('alamat')->nullable();
            $table->string('no_kk')->nullable()->comment('Dari OCR KK');
            
            // --- INI PERBAIKANNYA ---
            $table->string('no_telp')->nullable(); // Tambahkan kolom no_telp
            // --- AKHIR PERBAIKAN ---
            
            $table->enum('status_keluarga', ['Kepala Keluarga', 'Suami', 'Istri', 'Anak', 'Lain-lain'])->nullable();
            $table->string('foto_ktp_path')->nullable()->comment('Jalur penyimpanan foto KTP (untuk Face Verification)');
            $table->boolean('is_verified')->default(false)->comment('Verifikasi data warga baru');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('warga');
    }
};