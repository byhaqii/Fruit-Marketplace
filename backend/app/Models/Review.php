<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    protected $table = 'reviews';

    protected $fillable = [
        'produk_id', 'warga_id', 'rating', 'komentar'
    ];

    // Relasi ke Produk
    public function produk()
    {
        return $this->belongsTo(Produk::class);
    }

    // Relasi ke Warga (pemberi review)
    public function warga()
    {
        return $this->belongsTo(Warga::class);
    }
}