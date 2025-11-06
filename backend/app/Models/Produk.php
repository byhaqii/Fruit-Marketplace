<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    protected $table = 'produk';

    protected $fillable = [
        'warga_id', 'nama_produk', 'deskripsi', 'harga', 'stok', 
        'foto_produk_path', 'kategori', 'status_jual'
    ];

    // Relasi ke Warga (sebagai penjual)
    public function penjual()
    {
        return $this->belongsTo(Warga::class, 'warga_id');
    }

    // Relasi ke Review
    public function reviews()
    {
        return $this->hasMany(Review::class);
    }
}