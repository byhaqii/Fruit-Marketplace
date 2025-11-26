<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    /**
     * Lihat Profil (termasuk Saldo & Avatar)
     * GET /profile
     */
    public function show()
    {
        // Mengembalikan data user yang sedang login
        return response()->json(Auth::user());
    }

    /**
     * Update Profil (Nama, Email, Password, Avatar, Mobile Number, Alamat)
     * PUT /profile
     */
    public function update(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        $this->validate($request, [
            'name' => 'string|max:255',
            'email' => 'email|unique:users,email,' . $user->id,
            'password' => 'nullable|string|min:6',
            'avatar' => 'nullable|image|max:2048', 
            'alamat' => 'nullable|string',
            'mobile_number' => 'nullable|string', // <-- TAMBAH VALIDASI
        ]);

        // FIX: Update field standar, MENGGANTI 'phone' menjadi 'mobile_number'
        // Jika database Anda juga memiliki kolom 'phone' dan ingin diisi, Anda bisa menambahkannya.
        $user->fill($request->only(['name', 'email', 'alamat', 'mobile_number']));

        // Update Password jika diisi
        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }

        // Update Avatar jika diupload
        if ($request->hasFile('avatar')) {
            // Logika menyimpan file avatar...
            if ($user->avatar && file_exists(base_path('public/storage/profiles/' . $user->avatar))) {
                @unlink(base_path('public/storage/profiles/' . $user->avatar));
            }

            $file = $request->file('avatar');
            $filename = 'user_' . $user->id . '_' . time() . '.' . $file->getClientOriginalExtension();
            
            if (!file_exists(base_path('public/storage/profiles'))) {
                mkdir(base_path('public/storage/profiles'), 0777, true);
            }

            $file->move(base_path('public/storage/profiles'), $filename);
            $user->avatar = $filename;
        }

        $user->save();

        return response()->json([
            'message' => 'Profil berhasil diperbarui',
            'user' => $user
        ]);
    }
}