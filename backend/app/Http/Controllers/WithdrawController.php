<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use App\Models\User;
use App\Models\Withdrawal; 

class WithdrawController extends Controller
{
    // Penjual request penarikan
    public function store(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = User::find(Auth::id()); 
        
        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }
        
        $this->validate($request, [
            'amount' => 'required|numeric|min:10000',
            'bank_name' => 'required|string',
            'account_number' => 'required|string',
            'account_holder' => 'required|string',
        ]);

        if ($user->saldo < $request->amount) {
            return response()->json(['message' => 'Saldo tidak mencukupi'], 400);
        }

        DB::beginTransaction();
        try {
            // FIX P1080: Gunakan Query Builder explisit (User::where) agar tidak dianggap protected method
            User::where('id', $user->id)->decrement('saldo', $request->amount);

            // 2. Catat request
            $wd = Withdrawal::create([
                'user_id' => $user->id,
                'amount' => $request->amount,
                'bank_name' => $request->bank_name,
                'account_number' => $request->account_number,
                'account_holder' => $request->account_holder,
                'status' => 'pending'
            ]);

            DB::commit();
            return response()->json(['message' => 'Permintaan penarikan berhasil dibuat', 'data' => $wd]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Gagal', 'error' => $e->getMessage()], 500);
        }
    }

    // Admin menyetujui/menolak
    public function updateStatus(Request $request, $id)
    {
        // Hanya Admin
        if (Auth::user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $this->validate($request, [
            'status' => 'required|in:approved,rejected'
        ]);

        $wd = Withdrawal::find($id);
        if (!$wd || $wd->status !== 'pending') {
            return response()->json(['message' => 'Data tidak valid'], 404);
        }

        if ($request->status === 'rejected') {
            // Kalau ditolak, KEMBALIKAN saldo ke user
            // Gunakan Query Builder juga di sini untuk konsistensi
            User::where('id', $wd->user_id)->increment('saldo', $wd->amount);
        }

        $wd->update(['status' => $request->status]);

        return response()->json(['message' => 'Status diperbarui']);
    }
    
    // List history withdraw (Bisa buat admin atau user sendiri)
    public function index()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        
        if ($user->role === 'admin') {
            return response()->json(Withdrawal::with('user')->latest()->get());
        }
        return response()->json(Withdrawal::where('user_id', $user->id)->latest()->get());
    }
}