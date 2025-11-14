<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class ProfileController extends Controller
{
    /**
     * Mendapatkan data user yang sedang login (profil mereka).
     * Middleware 'auth' sudah menangani otentikasi.
     * GET /profile
     */
    public function show(Request $request): JsonResponse
    {
        // Karena rute ini dilindungi oleh middleware 'auth',
        // kita bisa langsung mengambil user yang sedang login.
        $user = Auth::user(); 
        
        return response()->json($user);
    }

    /**
     * Memperbarui profil user yang sedang login.
     * PUT /profile
     */
    public function update(Request $request): JsonResponse
    {
        $user = Auth::user(); // Ambil user yang sedang login

        // Validasi
        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255',
            // Pastikan email unik, KECUALI untuk ID user ini sendiri
            'email' => 'string|email|unique:users,email,' . $user->id,
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Input tidak valid', 'errors' => $validator->errors()], 422);
        }

        // Update data user
        $user->fill($request->only(['name', 'email']));

        // Jika user juga mengirim password baru, hash dan update
        if ($request->has('password') && $request->password) {
            $user->password = Hash::make($request->password);
        }

        $user->save();

        return response()->json([
            'message' => 'Profil berhasil diperbarui',
            'data' => $user
        ]);
    }
}