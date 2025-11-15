<?php

namespace App\Http\Controllers;

use App\Models\Produk; // Import Model Produk
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Auth;

class ProdukController extends Controller
{
    /**
     * Menampilkan semua produk (Publik)
     * [READ - Bagian dari R]
     */
    public function index(): JsonResponse
    {
        $produk = Produk::orderBy('nama_produk', 'asc')->get();
        return response()->json($produk);
    }

    /**
     * Menampilkan satu produk (Publik)
     * [READ - Bagian dari R]
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
     * [CREATE - Bagian dari C]
     */
    public function store(Request $request): JsonResponse
    {
        $user = Auth::user(); 

        // 1. Otorisasi (Admin atau Penjual)
        if (!in_array($user->role, ['admin', 'penjual'])) {
            return response()->json(['message' => 'Anda tidak memiliki hak akses untuk menambah produk'], 403);
        }

        // 2. Validasi Input (DILENGKAPI)
        try {
            $this->validate($request, [
                'nama_produk' => 'required|string|max:255',
                'deskripsi' => 'nullable|string',
                'harga' => 'required|numeric|min:0',
                'stok' => 'required|integer|min:0',
                'kategori' => 'nullable|string|max:100', // Sesuai model Produk.php
                'gambar_url' => 'nullable|string|max:255', // Sesuai model Produk.php
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        // 3. Buat Produk
        // Menggunakan ::create() lebih rapi jika 'user_id' ada di $fillable
        $data = $request->all();
        $data['user_id'] = $user->id; // Tetapkan penjualnya
        
        $produk = Produk::create($data); // Menggunakan create

        return response()->json($produk, 201); // 201 Created
    }

    /**
     * Memperbarui produk (Dilindungi: 'admin' atau 'penjual' pemilik)
     * [UPDATE - Bagian dari U]
     */
    public function update(Request $request, $id): JsonResponse
    {
        $user = Auth::user();
        $produk = Produk::find($id);
        
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        // 1. Otorisasi (Admin BISA update SEMUA, Penjual hanya milik sendiri)
        if ($user->role !== 'admin' && $produk->user_id !== $user->id) {
            return response()->json(['message' => 'Anda tidak memiliki hak akses untuk mengubah produk ini'], 403);
        }

        // 2. Validasi (DILENGKAPI)
        try {
             $this->validate($request, [
                'nama_produk' => 'string|max:255',
                'deskripsi' => 'nullable|string',
                'harga' => 'numeric|min:0',
                'stok' => 'integer|min:0',
                'kategori' => 'nullable|string|max:100',
                'gambar_url' => 'nullable|string|max:255',
                'status_jual' => 'in:Tersedia,Habis,Nonaktif' // Validasi status
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        // 3. Update
        $produk->update($request->all());

        return response()->json($produk);
    }

    /**
     * Menghapus produk (Dilindungi: 'admin' atau 'penjual' pemilik)
     * [DELETE - Bagian dari D]
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        $user = Auth::user();
        $produk = Produk::find($id);

        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        // 1. Otorisasi (Admin BISA hapus SEMUA, Penjual hanya milik sendiri)
        if ($user->role !== 'admin' && $produk->user_id !== $user->id) {
             return response()->json(['message' => 'Anda tidak memiliki hak akses untuk menghapus produk ini'], 403);
        }

        // 2. Hapus
        $produk->delete();

        return response()->json(['message' => 'Produk berhasil dihapus']);
    }
}