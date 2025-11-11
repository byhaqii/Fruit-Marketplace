<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class UserController extends Controller
{
    /**
     * Memeriksa apakah pengguna yang login adalah Admin.
     */
    private function isAdmin(Request $request): bool
    {
        return $request->user()->role === 'admin';
    }

    /**
     * Menampilkan semua pengguna (Hanya Admin).
     * GET /users
     */
    public function index(Request $request): JsonResponse
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        $users = User::all();
        return response()->json($users);
    }

    /**
     * Menampilkan satu pengguna (Hanya Admin).
     * GET /users/{id}
     */
    public function show(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        $user = User::find($id);
        if (!$user) {
            return response()->json(['message' => 'Pengguna tidak ditemukan'], 404);
        }
        return response()->json($user);
    }

    /**
     * Menyimpan pengguna baru (Hanya Admin).
     * POST /users
     */
    public function store(Request $request): JsonResponse
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        try {
            $this->validate($request, [
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|string|min:6',
                'role' => 'required|in:admin,ketua_rt,ketua_rw,bendahara,sekretaris,warga', // Validasi role
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        $user = User::create([
            'name' => $request->input('name'),
            'email' => $request->input('email'),
            'password' => Hash::make($request->input('password')),
            'role' => $request->input('role'),
        ]);

        return response()->json($user, 201); // 201 Created
    }

    /**
     * Memperbarui pengguna (Hanya Admin).
     * PUT /users/{id}
     */
    public function update(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        $user = User::find($id);
        if (!$user) {
            return response()->json(['message' => 'Pengguna tidak ditemukan'], 404);
        }

        try {
            $this->validate($request, [
                'name' => 'string|max:255',
                'email' => 'email|unique:users,email,'.$id, // Unik, kecuali untuk ID ini sendiri
                'role' => 'in:admin,ketua_rt,ketua_rw,bendahara,sekretaris,warga',
                'password' => 'nullable|string|min:6', // Password opsional untuk diubah
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        // Update data dasar
        $user->fill($request->only(['name', 'email', 'role']));

        // Update password jika diisi
        if ($request->has('password')) {
            $user->password = Hash::make($request->input('password'));
        }
        
        $user->save();

        return response()->json($user);
    }

    /**
     * Menghapus pengguna (Hanya Admin).
     * DELETE /users/{id}
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        $user = User::find($id);
        if (!$user) {
            return response()->json(['message' => 'Pengguna tidak ditemukan'], 404);
        }
        
        // TODO: Tambahkan logika untuk mencegah admin menghapus akunnya sendiri
        // if ($request->user()->id == $id) {
        //     return response()->json(['message' => 'Anda tidak dapat menghapus akun Anda sendiri'], 403);
        // }

        $user->delete();

        return response()->json(['message' => 'Pengguna berhasil dihapus']);
    }
}