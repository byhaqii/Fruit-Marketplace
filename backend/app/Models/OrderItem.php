<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model

{
    // Nama tabel
    protected $table = 'order_items';

    /**
     * 
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
     * 
     */
    public function transaksi()
    {
        return $this->belongsTo(Transaksi::class);
    }

    /**
     * 
     */
    public function produk()
    {
        return $this->belongsTo(Produk::class);
    }
}