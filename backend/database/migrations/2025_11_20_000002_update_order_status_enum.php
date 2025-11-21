<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // Jika menggunakan MySQL, kita bisa memodifikasi kolom enum
        // Perintah ini mengubah definisi kolom order_status
        DB::statement("ALTER TABLE transaksi MODIFY COLUMN order_status ENUM(
            'menunggu konfirmasi', 
            'Diproses', 
            'Dikirim', 
            'Tiba di tujuan', 
            'Selesai', 
            'Dibatalkan',
            'Cancel'
        ) NOT NULL DEFAULT 'menunggu konfirmasi'");
    }

    public function down()
    {
        // Kembalikan ke status awal jika rollback
        DB::statement("ALTER TABLE transaksi MODIFY COLUMN order_status ENUM(
            'menunggu konfirmasi', 
            'Diproses', 
            'Dikirim', 
            'Selesai', 
            'Dibatalkan'
        ) NOT NULL DEFAULT 'menunggu konfirmasi'");
    }
};
