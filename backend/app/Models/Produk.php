<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    use HasFactory;

    protected $table = 'produk';

    protected $fillable = [
        'nama_produk',
        'deskripsi',
        'harga',
        'stok',
        'kategori',
        'gambar_url',
    ];

    /**
     * Relasi BARU: Satu produk bisa ada di BANYAK order_items
     */
    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }
    
    /**
     * Relasi ke Review (ini seharusnya sudah ada)
     */
    public function reviews()
    {
        return $this->hasMany(Review::class);
    }
}