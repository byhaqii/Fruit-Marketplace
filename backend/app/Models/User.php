<?php

namespace App\Models;

// Tambah semua USE statements yang diperlukan
use Illuminate\Auth\Authenticatable;
use Illuminate\Contracts\Auth\Access\Authorizable as AuthorizableContract;
use Illuminate\Contracts\Auth\Authenticatable as AuthenticatableContract;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model; // Pastikan ini terimpor
use Laravel\Lumen\Auth\Authorizable;

class User extends Model implements AuthenticatableContract, AuthorizableContract
{
    use Authenticatable, Authorizable, HasFactory;

    protected $table = 'users';

    /**
     * The attributes that are mass assignable.
     *
     * @var string[]
     */
    protected $fillable = [
        'name', 'email', 'password', 'role', 'api_token'
    ];

    /**
     * The attributes excluded from the model's JSON form.
     *
     * @var string[]
     */
    protected $hidden = [
        'password', 'api_token',
    ];
    
    // --- PERBAIKAN ---
    // Relasi 'warga()' DIHAPUS karena tabel 'warga' sudah tidak relevan
    // dengan skema baru 'penjual'/'pembeli'.

    /**
     * Relasi opsional: Seorang User (jika rolenya 'penjual') bisa memiliki banyak Produk.
     */
    public function produk()
    {
        // Asumsi foreign key di tabel 'produk' adalah 'user_id'
        return $this->hasMany(Produk::class, 'user_id');
    }

    /**
     * Relasi opsional: Seorang User (jika rolenya 'pembeli') bisa memiliki banyak Review.
     */
    public function reviews()
    {
        // Asumsi foreign key di tabel 'reviews' adalah 'user_id'
        return $this->hasMany(Review::class, 'user_id');
    }

    /**
     * Relasi opsional: Seorang User (jika rolenya 'pembeli') bisa memiliki banyak Transaksi.
     */
    public function transaksi()
    {
        return $this->hasMany(Transaksi::class, 'user_id');
    }
}