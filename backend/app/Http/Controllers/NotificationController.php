<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    /**
     * Ambil semua notifikasi user (terbaru di atas)
     */
    public function index()
    {
        $userId = Auth::id();
        $notif = Notification::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->limit(50) // Batasi 50 terakhir agar ringan
            ->get();

        return response()->json($notif);
    }

    /**
     * Tandai semua sebagai sudah dibaca
     */
    public function markAllRead()
    {
        $userId = Auth::id();
        Notification::where('user_id', $userId)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json(['message' => 'Semua notifikasi ditandai sudah dibaca']);
    }
}