<?php

namespace App\Http\Controllers;

use App\Models\Produk; // <-- Import Model Produk
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

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
     * Menyimpan produk baru (Dilindungi: RT/RW & Sekretaris)
     */
    public function store(Request $request): JsonResponse
    {
        // 1. Otorisasi (Cek Role)
        $user = $request->user();
        if ($user->role !== 'admin' && $user->role !== 'ketua_rt' && $user->role !== 'ketua_rw' && $user->role !== 'sekretaris') {
            return response()->json(['message' => 'Anda tidak memiliki hak akses untuk menambah produk'], 403); // 403 Forbidden
        }

        // 2. Validasi Input
        try {
            $this->validate($request, [
                'nama_produk' => 'required|string|max:255',
                'deskripsi' => 'nullable|string',
                'harga' => 'required|numeric|min:0',
                'stok' => 'required|integer|min:0',
                // 'foto_produk_path' => 'nullable|string', // (Handle upload file jika diperlukan)
            ]);
        } catch (ValidationException $e) {
             return response()->json([
                'message' => 'Input tidak valid',
                'errors' => $e->errors()
            ], 422);
        }

        // 3. Buat Produk
        $produk = new Produk;
        $produk->nama_produk = $request->input('nama_produk');
        $produk->deskripsi = $request->input('deskripsi');
        $produk->harga = $request->input('harga');
        $produk->stok = $request->input('stok');
        
        // Asumsi 'warga_id' diambil dari user yang login (misal, RT)
        // Kita perlu menghubungkan User ke Warga
        $warga = $user->warga; // (Membutuhkan relasi 'warga' di Model User)
        if (!$warga) {
             return response()->json(['message' => 'Profil warga tidak ditemukan untuk pengguna ini'], 400);
        }
        $produk->warga_id = $warga->id; // Penjual adalah RT/Sekretaris yang login
        
        $produk->save();

        return response()->json($produk, 201); // 201 Created
    }

    /**
     * Memperbarui produk (Dilindungi: RT/RW & Sekretaris)
     */
    public function update(Request $request, $id): JsonResponse
    {
        // 1. Otorisasi
        $user = $request->user();
        if ($user->role !== 'admin' && $user->role !== 'ketua_rt' && $user->role !== 'ketua_rw' && $user->role !== 'sekretaris') {
            return response()->json(['message' => 'Anda tidak memiliki hak akses untuk mengubah produk'], 403);
        }

        $produk = Produk::find($id);
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        // 2. Validasi
        try {
             $this->validate($request, [
                'nama_produk' => 'string|max:255',
                'harga' => 'numeric|min:0',
                'stok' => 'integer|min:0',
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        // 3. Update
        $produk->update($request->all()); // Update cepat

        return response()->json($produk);
    }

    /**
     * Menghapus produk (Dilindungi: RT/RW & Sekretaris)
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        // 1. Otorisasi
        $user = $request->user();
        if ($user->role !== 'admin' && $user->role !== 'ketua_rt' && $user->role !== 'ketua_rw') {
             return response()->json(['message' => 'Hanya Admin/RT/RW yang dapat menghapus produk'], 403);
        }

        $produk = Produk::find($id);
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        $produk->delete();

        return response()->json(['message' => 'Produk berhasil dihapus']);
    }
}