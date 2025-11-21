<?php

namespace App\Models;

use Illuminate\Auth\Authenticatable;
use Illuminate\Contracts\Auth\Access\Authorizable as AuthorizableContract;
use Illuminate\Contracts\Auth\Authenticatable as AuthenticatableContract;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Lumen\Auth\Authorizable;

class User extends Model implements AuthenticatableContract, AuthorizableContract
{
    use Authenticatable, Authorizable, HasFactory;

    protected $table = 'users';

    protected $fillable = [
        'name', 
        'email', 
        'password', 
        'role', 
        'api_token', 
        'alamat',
        'avatar', // <-- TAMBAHKAN INI
        'saldo',  // <-- TAMBAHKAN INI
    ];

    protected $hidden = [
        'password', 'api_token',
    ];
    
    // Casting agar saldo otomatis jadi tipe data float/integer, bukan string
    protected $casts = [
        'saldo' => 'float',
    ];

    public function produk()
    {
        return $this->hasMany(Produk::class, 'user_id');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class, 'user_id');
    }

    public function transaksi()
    {
        return $this->hasMany(Transaksi::class, 'user_id');
    }
}
