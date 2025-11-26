<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Notification; // <-- Import Model Notification
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Mendaftarkan pengguna baru.
     * POST /auth/register
     */
    public function register(Request $request): JsonResponse
    {
        try {
            $this->validate($request, [
                'name' => 'required|string|max:255',
                'email' => 'required|string|email|max:255|unique:users',
                'password' => 'required|string|min:6',
            ]);
        } catch (ValidationException $e) {
            return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        // 1. Buat User Baru
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'api_token' => Str::random(60),
            'role' => 'pembeli', // Default role
        ]);

        // 2. [LOG ACTIVITY] Catat pendaftaran user baru
        try {
            Notification::create([
                'user_id'    => $user->id, 
                'title'      => 'User Baru',
                'body'       => "Pengguna baru bernama '{$user->name}' telah mendaftar.",
                'type'       => 'info',
                'is_read'    => false,
            ]);
        } catch (\Exception $e) {
            // Ignore log error
        }

        return response()->json([
            'message' => 'Registrasi berhasil',
            'user' => $user,
            'api_token' => $user->api_token
        ], 201);
    }

    /**
     * Login pengguna.
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

        // Refresh token jika kosong
        if (!$user->api_token) {
            $user->api_token = Str::random(60);
            $user->save();
        }

        return response()->json([
            'message' => 'Login berhasil',
            'user' => $user,
            'api_token' => $user->api_token
        ]);
    }

    /**
     * Logout pengguna.
     * POST /auth/logout
     */
    public function logout(Request $request): JsonResponse
    {
        $user = $request->user(); 
        
        if ($user) {
            $user->api_token = null;
            $user->save();
            return response()->json(['message' => 'Logout berhasil']);
        }

        return response()->json(['message' => 'Tidak ada user yang login'], 400);
    }
}