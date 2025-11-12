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

    protected $fillable = [
        'name', 'email', 'password', 'role', 'api_token'
    ];

    protected $hidden = [
        'password', 'api_token',
    ];
    
    public function warga()
    {
        return $this->hasOne(Warga::class); 
    }
}