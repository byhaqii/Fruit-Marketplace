<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\OrderItem;

class Transaksi extends Model
{
    use HasFactory;

    protected $table = 'transaksi';

    protected $fillable = [
        'user_id',
        'order_id',
        'total_harga',
        'order_status',
        'payment_method',
        'payment_status',
        'bukti_bayar_url',
        'payment_gateway_ref',
        'alamat_pengiriman',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relasi: Satu transaksi memiliki BANYAK order_items
     * RENAME from items() to orderItems() to avoid conflict with Collection::$items
     */
    public function orderItems()
    {
        return $this->hasMany(OrderItem::class, 'transaksi_id');
    }
}