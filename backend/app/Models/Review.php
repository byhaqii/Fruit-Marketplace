<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    protected $table = 'reviews';

    // --- PERUBAHAN DI SINI ---
    protected $fillable = [
        'produk_id', 'user_id', 'rating', 'komentar' // Ganti warga_id menjadi user_id
    ];
    // --- AKHIR PERUBAHAN ---

    // Relasi ke Produk
    public function produk()
    {
        return $this->belongsTo(Produk::class);
    }

    // --- PERUBAHAN DI SINI ---
    // Relasi ke User (pemberi review)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
    // --- AKHIR PERUBAHAN ---
}