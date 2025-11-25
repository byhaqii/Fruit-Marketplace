<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaksi extends Model
{
    protected $table = 'transaksi';

    protected $fillable = [
        'user_id',
        'order_id',
        'total_harga',
        'ongkos_kirim',    // <-- Baru
        'kurir',           // <-- Baru
        'layanan_kurir',   // <-- Baru
        'nomor_resi',      // <-- Baru
        'order_status',
        'payment_method',
        'payment_status',
        'bukti_bayar_url',
        'alamat_pengiriman',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items() // Saya ubah kembali ke 'items' agar konsisten dengan Controller
    {
        return $this->hasMany(OrderItem::class, 'transaksi_id');
    }
}