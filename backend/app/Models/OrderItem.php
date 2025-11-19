<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

// KEMBALIKAN NAMA CLASS KE SEMULA (OrderItem)
class OrderItem extends Model
{
    // Nama tabel
    protected $table = 'order_items';

    /**
     * Tentukan field yang boleh diisi secara massal.
     *
     * @var array
     */
    protected $fillable = [
        'transaksi_id',
        'produk_id',
        'jumlah',
        'harga_saat_beli',
    ];

    /**
     * Relasi ke model Transaksi (Order Header)
     */
    public function transaksi()
    {
        return $this->belongsTo(Transaksi::class);
    }

    /**
     * Relasi ke model Produk
     */
    public function produk()
    {
        return $this->belongsTo(Produk::class);
    }
}