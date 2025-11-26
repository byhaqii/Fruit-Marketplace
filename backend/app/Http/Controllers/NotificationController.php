<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    /**
     * UNTUK USER BIASA: Ambil notifikasi milik sendiri.
     * GET /notifications
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
     * KHUSUS ADMIN: Ambil semua aktivitas sistem (Activity Log).
     * GET /admin/activities
     */
    public function getActivities(Request $request)
    {
        // Cek hak akses Admin
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Ambil notifikasi dari seluruh user untuk dijadikan Log
        $activities = Notification::with('user') // Include data user pelakunya
            ->orderBy('created_at', 'desc')
            ->limit(20) // Batasi 20 aktivitas terakhir
            ->get();

        return response()->json($activities);
    }

    /**
     * Tandai semua sebagai sudah dibaca.
     * POST /notifications/read-all
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