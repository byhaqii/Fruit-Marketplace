<?php

namespace App\Http\Controllers;

use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Auth;

class ProdukController extends Controller
{
    public function index(): JsonResponse
    {
        $produk = Produk::orderBy('nama_produk', 'asc')->get();
        return response()->json($produk);
    }

    public function show($id): JsonResponse
    {
        $produk = Produk::find($id);
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }
        return response()->json($produk);
    }

    // --- PERBAIKAN FUNGSI STORE (TAMBAH) ---
    public function store(Request $request): JsonResponse
    {
        $user = Auth::user(); 

        if (!in_array($user->role, ['admin', 'penjual'])) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        try {
            $this->validate($request, [
                'nama_produk' => 'required|string|max:255',
                'deskripsi' => 'nullable|string',
                'harga' => 'required|numeric|min:0',
                'stok' => 'required|integer|min:0',
                'kategori' => 'nullable|string',
                'image' => 'nullable|image|max:2048', // Validasi file image
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        $data = $request->all();
        $data['user_id'] = $user->id;

        // LOGIKA UPLOAD GAMBAR
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $filename = time() . '_' . $file->getClientOriginalName();
            // Simpan ke folder 'public/storage'
            $file->move(base_path('public/storage'), $filename);
            // Simpan nama file ke database
            $data['gambar_url'] = $filename; 
        }

        $produk = Produk::create($data);

        return response()->json($produk, 201);
    }

    // --- PERBAIKAN FUNGSI UPDATE (EDIT) ---
    public function update(Request $request, $id): JsonResponse
    {
        $user = Auth::user();
        $produk = Produk::find($id);
        
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        if ($user->role !== 'admin' && $produk->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        try {
             $this->validate($request, [
                'nama_produk' => 'string|max:255',
                'deskripsi' => 'nullable|string',
                'harga' => 'numeric|min:0',
                'stok' => 'integer|min:0',
                'image' => 'nullable|image|max:2048', // Validasi image
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        $data = $request->all();

        // LOGIKA UPDATE GAMBAR
        if ($request->hasFile('image')) {
            // Hapus gambar lama jika ada (Opsional, biar server gak penuh)
            if ($produk->gambar_url && file_exists(base_path('public/storage/' . $produk->gambar_url))) {
                unlink(base_path('public/storage/' . $produk->gambar_url));
            }

            $file = $request->file('image');
            $filename = time() . '_' . $file->getClientOriginalName();
            $file->move(base_path('public/storage'), $filename);
            $data['gambar_url'] = $filename;
        }

        $produk->update($data);

        return response()->json($produk);
    }

    public function destroy(Request $request, $id): JsonResponse
    {
        $user = Auth::user();
        $produk = Produk::find($id);

        if (!$produk) return response()->json(['message' => 'Not Found'], 404);

        if ($user->role !== 'admin' && $produk->user_id !== $user->id) {
             return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Hapus file fisik saat data dihapus
        if ($produk->gambar_url && file_exists(base_path('public/storage/' . $produk->gambar_url))) {
            unlink(base_path('public/storage/' . $produk->gambar_url));
        }

        $produk->delete();

        return response()->json(['message' => 'Produk berhasil dihapus']);
    }
}