<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class ProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $user = Auth::user();
        // Tambahkan full URL untuk avatar agar Frontend tinggal pakai
        if ($user->avatar) {
            $user->avatar_url = url('storage/profiles/' . $user->avatar);
        }
        return response()->json($user);
    }

    public function update(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        $validator = Validator::make($request->all(), [
            'name'   => 'string|max:255',
            'email'  => 'string|email|unique:users,email,' . $user->id,
            'alamat' => 'string|nullable',
            'image'  => 'nullable|image|max:2048', 
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Input tidak valid', 'errors' => $validator->errors()], 422);
        }

        $user->fill($request->only(['name', 'email', 'alamat']));

        if ($request->has('password') && $request->password) {
            $user->password = Hash::make($request->password);
        }

        // LOGIKA UPLOAD & SIMPAN PATH
        if ($request->hasFile('image')) {
            // Hapus foto lama
            if ($user->avatar && file_exists(base_path('public/storage/profiles/' . $user->avatar))) {
               unlink(base_path('public/storage/profiles/' . $user->avatar));
            }

            $file = $request->file('image');
            // Nama file unik
            $filename = 'profile_' . $user->id . '_' . time() . '.' . $file->getClientOriginalExtension();
            
            $file->move(base_path('public/storage/profiles'), $filename);
            
            // SIMPAN NAMA FILE SAJA KE DATABASE
            $user->avatar = $filename; 
        }

        $user->save();

        // Return data user terbaru + URL avatar
        if ($user->avatar) {
            $user->avatar_url = url('storage/profiles/' . $user->avatar);
        }

        return response()->json([
            'message' => 'Profil berhasil diperbarui',
            'data' => $user
        ]);
    }
}