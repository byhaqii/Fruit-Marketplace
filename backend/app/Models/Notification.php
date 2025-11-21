<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    protected $table = 'notifications';

    protected $fillable = [
        'user_id',
        'title',
        'body',
        'type',       // 'order', 'info', 'promo'
        'is_read',
        'related_id', // Misal ID Transaksi
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}