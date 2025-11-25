<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    protected $fillable = [
        'user_id', 'title', 'body', 'type', 'is_read', 'related_id'
    ];

    protected $casts = [
        'is_read' => 'boolean'
    ];
}