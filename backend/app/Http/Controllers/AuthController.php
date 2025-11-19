<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Mendaftarkan pengguna baru (default sebagai 'pembeli').
     * POST /auth/register
     */
    public function register(Request $request): JsonResponse
    {
        try {
            $this->validate($request, [
                'name' => 'required|string|max:255',
                'email' => 'required|string|email|max:255|unique:users',
                'password' => 'required|string|min:6', // Sesuaikan min:6 jika perlu
            ]);
        } catch (ValidationException $e) {
            return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'api_token' => Str::random(60),
            // 'role' akan otomatis 'pembeli' sesuai pengaturan default di migrasi
        ]);

        return response()->json([
            'message' => 'Registrasi berhasil',
            'user' => $user,
            'api_token' => $user->api_token // Kembalikan token saat registrasi
        ], 201);
    }

    /**
     * Login pengguna dan hasilkan token.
     * POST /auth/login
     */
    public function login(Request $request): JsonResponse
    {
        try {
            $this->validate($request, [
                'email' => 'required|string|email',
                'password' => 'required|string',
            ]);
        } catch (ValidationException $e) {
            return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Email atau password salah'], 401);
        }

        // Buat token baru jika belum ada atau null
        if (!$user->api_token) {
            $user->api_token = Str::random(60);
            $user->save(); // Method .save() ada di sini dan sudah benar
        }

        return response()->json([
            'message' => 'Login berhasil',
            'user' => $user,
            'api_token' => $user->api_token
        ]);
    }

    /**
     * Logout pengguna (hapus token).
     * POST /auth/logout
     */
    public function logout(Request $request): JsonResponse
    {
        // Middleware 'auth' akan memastikan user sudah login
        $user = $request->user(); 
        
        if ($user) {
            $user->api_token = null; // Hapus token
            $user->save(); // Method .save() ada di sini dan sudah benar
            return response()->json(['message' => 'Logout berhasil']);
        }

        return response()->json(['message' => 'Tidak ada user yang login'], 400);
    }

    // Fungsi profile() telah dipindahkan ke ProfileController.php
}