<?php

namespace App\Http\Controllers;

// Tambahkan semua USE statements yang diperlukan
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Illuminate\Http\JsonResponse; // Gunakan ini untuk respon yang konsisten

class AuthController extends Controller
{
    /**
     * Menangani permintaan login.
     */
    public function login(Request $request): JsonResponse
    {
        try {
            // $this->validate() adalah method dari BaseController Lumen
            $this->validate($request, [ 
                'email' => 'required|email',
                'password' => 'required'
            ]);
        } catch (ValidationException $e) {
             return response()->json([
                'message' => 'Input tidak valid',
                'errors' => $e->errors()
            ], 422);
        }

        $user = User::where('email', $request->input('email'))->first();

        if (!$user || !Hash::check($request->input('password'), $user->password)) {
            return response()->json([
                'message' => 'Email atau password salah.'
            ], 401);
        }

        // Generate new API Token on successful login
        $user->api_token = Str::random(60);
        $user->save();

        return response()->json([
            'message' => 'Login berhasil',
            'token' => $user->api_token,
            'role' => $user->role,
        ]);
    }
    
    /**
     * Menangani permintaan logout.
     */
    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();
        if ($user) {
            $user->api_token = null;
            $user->save();
        }

        return response()->json(['message' => 'Logout berhasil']);
    }
}