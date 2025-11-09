<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Warga extends Model
{
    protected $table = 'warga';
    
    protected $fillable = [
        'user_id', 'nik', 'nama', 'tempat_lahir', 'tanggal_lahir', 
        'jenis_kelamin', 'alamat', 'no_kk', 'status_keluarga', 
        'foto_ktp_path', 'is_verified', // <--- KOMA SUDAH DITAMBAHKAN
        'no_telp'
    ];

    // Relasi ke User
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi ke Transaksi (untuk melihat iuran yang dibayar)
    public function transaksi()
    {
        return $this->hasMany(Transaksi::class);
    }

    // Relasi ke Produk (sebagai penjual)
    public function produk()
    {
        return $this->hasMany(Produk::class, 'warga_id');
    }
}