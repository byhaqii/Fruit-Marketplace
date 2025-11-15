<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    use HasFactory;

    protected $table = 'produk';

    protected $fillable = [
        'user_id',      // Pastikan ini ada dari langkah CRUD Admin
        'nama_produk',
        'deskripsi',
        'harga',
        'stok',
        'kategori',
        'gambar_url',   // Pastikan ini ada dari error sebelumnya
        'status_jual',  // Pastikan ini ada
    ];

    /**
     * Relasi ke User (Penjual)
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Relasi: Satu produk bisa ada di BANYAK order_items
     */
    public function orderItems()
    {
        // --- UBAH NAMA CLASS DI SINI ---
        return $this->hasMany(Order_Items::class);
    }
    
    /**
     * Relasi ke Review
     */
    public function reviews()
    {
        return $this->hasMany(Review::class);
    }
}