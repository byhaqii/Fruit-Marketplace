<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Iuran extends Model
{
    protected $table = 'iuran';

    protected $fillable = [
        'nama_iuran', 'deskripsi', 'jumlah', 'periode', 'is_aktif'
    ];
    
    // Relasi ke Transaksi
    public function transaksi()
    {
        return $this->hasMany(Transaksi::class);
    }
}