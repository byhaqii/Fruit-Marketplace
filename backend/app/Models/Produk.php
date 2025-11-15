<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    use HasFactory;

    protected $table = 'produk';

    // ... $fillable ...
    protected $fillable = [
        'user_id',
        'nama_produk',
        'deskripsi',
        'harga',
        'stok',
        'kategori',
        'gambar_url',
        'status_jual',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Relasi: Satu produk bisa ada di BANYAK order_items
     */
    public function orderItems()
    {
        // --- PERBAIKI DI SINI ---
        return $this->hasMany(OrderItem::class);
    }
    
    public function reviews()
    {
        return $this->hasMany(Review::class);
    }
}