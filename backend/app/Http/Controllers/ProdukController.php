<?php

namespace App\Http\Controllers;

use App\Models\Produk; // <-- Import Model Produk
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Auth; // <-- DIPERBAIKI: Pastikan ini ada

class ProdukController extends Controller
{
    /**
     * Menampilkan semua produk (Publik)
     */
    public function index(): JsonResponse
    {
        // Ambil semua produk dari database
        $produk = Produk::orderBy('nama_produk', 'asc')->get();
        return response()->json($produk);
    }

    /**
     * Menampilkan satu produk (Publik)
     */
    public function show($id): JsonResponse
    {
        $produk = Produk::find($id);
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }
        return response()->json($produk);
    }

    /**
     * Menyimpan produk baru (Dilindungi: 'admin' atau 'penjual')
     */
    public function store(Request $request): JsonResponse
    {
        $user = Auth::user(); // Menggunakan Auth::user() lebih eksplisit

        // 1. Otorisasi (Cek Role Baru)
        // Hanya admin dan penjual yang boleh menambah produk
        if (!in_array($user->role, ['admin', 'penjual'])) {
            return response()->json(['message' => 'Anda tidak memiliki hak akses untuk menambah produk'], 403);
        }

        // 2. Validasi Input
        try {
            $this->validate($request, [
                'nama_produk' => 'required|string|max:255',
                'deskripsi' => 'nullable|string',
                'harga' => 'required|numeric|min:0',
                'stok' => 'required|integer|min:0',
                // 'foto_produk_path' => 'nullable|string', 
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        // 3. Buat Produk
        $produk = new Produk;
        $produk->fill($request->all()); // Isi data dari request
        
        // Penjual adalah user yang sedang login
        $produk->user_id = $user->id; 
        
        $produk->save();

        return response()->json($produk, 201); // 201 Created
    }

    /**
     * Memperbarui produk (Dilindungi: 'admin' atau 'penjual' pemilik)
     */
    public function update(Request $request, $id): JsonResponse
    {
        $user = Auth::user();
        $produk = Produk::find($id);
        
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        // 1. Otorisasi
        // Boleh update JIKA dia admin ATAU dia penjual yang memiliki produk tsb
        if ($user->role !== 'admin' && $produk->user_id !== $user->id) {
            return response()->json(['message' => 'Anda tidak memiliki hak akses untuk mengubah produk ini'], 403);
        }

        // 2. Validasi
        try {
             $this->validate($request, [
                'nama_produk' => 'string|max:255',
                'harga' => 'numeric|min:0',
                'stok' => 'integer|min:0',
                'status_jual' => 'in:Tersedia,Habis,Nonaktif' // Validasi status jika diizinkan update
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        // 3. Update
        $produk->update($request->all());

        return response()->json($produk);
    }
    
    // <-- DIPERBAIKI: Fungsi update() yang duplikat dan salah telah dihapus -->

    /**
     * Menghapus produk (Dilindungi: 'admin' atau 'penjual' pemilik)
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        // --- DIPERBAIKI: Logika otorisasi disamakan dengan update ---
        
        $user = Auth::user();
        $produk = Produk::find($id);

        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        // 1. Otorisasi
        // Boleh hapus JIKA dia admin ATAU dia penjual yang memiliki produk tsb
        if ($user->role !== 'admin' && $produk->user_id !== $user->id) {
             return response()->json(['message' => 'Anda tidak memiliki hak akses untuk menghapus produk ini'], 403);
        }

        // 2. Hapus
        $produk->delete();

        return response()->json(['message' => 'Produk berhasil dihapus']);
    }
}