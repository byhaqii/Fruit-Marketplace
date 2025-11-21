<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class NotificationController extends Controller
{
    /**
     * Ambil semua notifikasi user yang login
     */
    public function index()
    {
        $user = Auth::user();
        
        // Asumsi nama tabel 'notifications'
        $notifs = DB::table('notifications')
            ->where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($notifs);
    }

    /**
     * Tandai semua sebagai sudah dibaca
     */
    public function markAllRead()
    {
        $user = Auth::user();

        DB::table('notifications')
            ->where('user_id', $user->id)
            ->update(['is_read' => true]);

        return response()->json(['message' => 'Semua notifikasi ditandai terbaca']);
    }
}