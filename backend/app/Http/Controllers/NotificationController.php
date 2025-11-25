<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    /**
     * 1. UNTUK USER BIASA: Ambil notifikasi milik sendiri
     */
    public function index()
    {
        $userId = Auth::id();
        $notif = Notification::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->limit(50)
            ->get();

        return response()->json($notif);
    }

    /**
     * 2. KHUSUS ADMIN: Ambil semua aktivitas sistem (Activity Log)
     * GET /admin/activities
     */
    public function getActivities(Request $request)
    {
        // Cek apakah user adalah admin
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Ambil notifikasi dari seluruh sistem untuk ditampilkan sebagai Log
        // Kita bisa memfilter tipe tertentu jika perlu
        $activities = Notification::with('user') // Load data user pelakunya
            ->orderBy('created_at', 'desc')
            ->limit(10) // Ambil 10 aktivitas terakhir
            ->get();

        return response()->json($activities);
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