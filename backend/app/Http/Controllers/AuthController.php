<?php

namespace App\Http\Controllers;

// Tambahkan semua USE statements yang diperlukan
use App\Models\User;
use App\Models\Warga;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Illuminate\Http\JsonResponse; 
use Illuminate\Support\Facades\DB;// Gunakan ini untuk respon yang konsisten

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

    public function register(Request $request): JsonResponse
    {
        try {
            // Validasi data yang dikirim dari RegisterForm
            $this->validate($request, [ 
                'name' => 'required|string|max:255', // Membutuhkan 'name' dari Flutter
                'email' => 'required|email|unique:users,email',
                'password' => 'required|min:6',
                'confirm_password' => 'required|same:password',
                'phone' => 'nullable|string',
            ]);
        } catch (ValidationException $e) {
             return response()->json([
                'message' => 'Input tidak valid',
                'errors' => $e->errors()
            ], 422);
        }

        // Gunakan Transaksi Database untuk memastikan data konsisten
        DB::beginTransaction();
        try {
            
            // 1. Buat User (Akun Login)
            $user = new User;
            $user->name = $request->input('name'); // Menggunakan 'name' dari form
            $user->email = $request->input('email');
            $user->password = Hash::make($request->input('password'));
            $user->role = 'warga'; // Role default untuk registrasi baru
            $user->save();

            // 2. Buat Warga (Profil Pembeli)
            $warga = new Warga;
            $warga->user_id = $user->id;
            $warga->nama = $user->name; // Samakan nama dengan user
            $warga->no_telp = $request->input('phone'); // Simpan nomor telepon (jika ada)
            $warga->nik = null; 
            $warga->no_kk = null;
            $warga->is_verified = false; 
            $warga->save();

            // Jika semua berhasil, commit transaksi
            DB::commit();

            return response()->json([
                'message' => 'Registrasi berhasil. Silakan login.'
            ], 201); // 201 = Created

        } catch (\Exception $e) {
            // Jika terjadi error, rollback semua data
            DB::rollBack();
            return response()->json([
                'message' => 'Registrasi gagal, terjadi kesalahan server.',
                'error' => $e->getMessage()
            ], 500);
        }
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

