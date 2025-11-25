<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    private function isAdmin(Request $request): bool
    {
        return $request->user() && $request->user()->role === 'admin';
    }

    public function index(Request $request): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);
        return response()->json(User::all());
    }

    public function show(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);
        $user = User::find($id);
        return $user ? response()->json($user) : response()->json(['message' => 'Not found'], 404);
    }

    // --- FITUR CREATE ---
    public function store(Request $request): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);

        try {
            $this->validate($request, [
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|string|min:6',
                'role' => 'required|in:admin,penjual,pembeli',
                'alamat' => 'nullable|string',          // Validasi tambahan
                'mobile_number' => 'nullable|string',   // Validasi tambahan
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        $user = User::create([
            'name' => $request->input('name'),
            'email' => $request->input('email'),
            'password' => Hash::make($request->input('password')),
            'role' => $request->input('role'),
            'alamat' => $request->input('alamat'),                  // Simpan Alamat
            'mobile_number' => $request->input('mobile_number'),    // Simpan No HP
        ]);

        return response()->json($user, 201);
    }

    // --- FITUR UPDATE ---
    public function update(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);
        
        $user = User::find($id);
        if (!$user) return response()->json(['message' => 'User tidak ditemukan'], 404);

        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255',
            'email' => 'string|email|unique:users,email,' . $id, 
            'role' => 'in:admin,penjual,pembeli',
            'password' => 'nullable|string|min:6',
            'alamat' => 'nullable|string',
            'mobile_number' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Input tidak valid', 'errors' => $validator->errors()], 422);
        }

        // Update data text termasuk alamat dan mobile_number
        $user->fill($request->only(['name', 'email', 'role', 'alamat', 'mobile_number']));

        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }

        $user->save();

        return response()->json(['message' => 'User berhasil diperbarui', 'data' => $user]);
    }

    public function destroy(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);
        $user = User::find($id);
        if (!$user) return response()->json(['message' => 'Not found'], 404);
        if ($request->user()->id == $id) return response()->json(['message' => 'Tidak bisa hapus diri sendiri'], 403);

        $user->delete();
        return response()->json(['message' => 'Pengguna berhasil dihapus']);
    }
}