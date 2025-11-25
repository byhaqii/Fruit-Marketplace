<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    /**
     * Lihat Profil (termasuk Saldo & Avatar)
     */
    public function show()
    {
        // Mengembalikan data user yang sedang login
        // Saldo sudah otomatis ter-casting ke float/int di Model User
        return response()->json(Auth::user());
    }

    /**
     * Update Profil (Nama, Email, Password, Avatar)
     */
    public function update(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        $this->validate($request, [
            'name' => 'string|max:255',
            'email' => 'email|unique:users,email,' . $user->id,
            'password' => 'nullable|string|min:6',
            'avatar' => 'nullable|image|max:2048', // Validasi Avatar
            'alamat' => 'nullable|string'
        ]);

        // Update field standar
        $user->fill($request->only(['name', 'email', 'alamat', 'phone']));

        // Update Password jika diisi
        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }

        // Update Avatar jika diupload
        if ($request->hasFile('avatar')) {
            // Hapus avatar lama jika bukan default (opsional)
            if ($user->avatar && file_exists(base_path('public/storage/profiles/' . $user->avatar))) {
                @unlink(base_path('public/storage/profiles/' . $user->avatar));
            }

            $file = $request->file('avatar');
            $filename = 'user_' . $user->id . '_' . time() . '.' . $file->getClientOriginalExtension();
            
            // Pastikan folder ada
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