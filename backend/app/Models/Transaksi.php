<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaksi extends Model
{
    use HasFactory;

    protected $table = 'transaksi';

    // ... $fillable Anda tetap sama ...
    protected $fillable = [
        'user_id',
        'order_id',
        'total_harga',
        'order_status',
        'payment_method',
        'payment_status',
        'bukti_bayar_url',
        'payment_gateway_ref',
        'alamat_pengiriman',
    ];


    /**
     * Relasi ke User (pembeli)
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relasi BARU: Satu transaksi memiliki BANYAK order_items
     */
    public function items()
    {
        // --- UBAH NAMA CLASS DI SINI ---
        return $this->hasMany(Order_Items::class);
    }
}