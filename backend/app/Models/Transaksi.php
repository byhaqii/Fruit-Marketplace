<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaksi extends Model
{
    protected $table = 'transaksi';

    protected $fillable = [
        'iuran_id', 'warga_id', 'nominal_bayar', 'metode_pembayaran', 
        'tanggal_bayar', 'bukti_transfer_path', 'status_verifikasi', 
        'verified_by_user_id', 'is_anomaly'
    ];
    
    // Relasi ke Iuran
    public function iuran()
    {
        return $this->belongsTo(Iuran::class);
    }

    // Relasi ke Warga (pembayar)
    public function warga()
    {
        return $this->belongsTo(Warga::class);
    }
}