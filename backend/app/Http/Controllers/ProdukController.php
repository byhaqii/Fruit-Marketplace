<?php

namespace App\Http\Controllers;

use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class ProdukController extends Controller
{
    public function index(): JsonResponse
    {
        // Tampilkan produk terbaru di atas
        $produk = Produk::with('user')->orderBy('created_at', 'desc')->get();
        return response()->json($produk);
    }

    public function show($id): JsonResponse
    {
        $produk = Produk::with('user')->find($id);
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }
        return response()->json($produk);
    }

    public function store(Request $request): JsonResponse
    {
        $user = Auth::user(); 

        if (!in_array($user->role, ['admin', 'penjual'])) {
            return response()->json(['message' => 'Hanya penjual yang bisa tambah produk'], 403);
        }

        try {
            $this->validate($request, [
                'nama_produk' => 'required|string|max:255',
                'deskripsi'   => 'nullable|string',
                'harga'       => 'required|numeric|min:0',
                'stok'        => 'required|integer|min:0',
                'kategori'    => 'nullable|string',
                'image'       => 'nullable|image|max:2048', // Max 2MB
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        // FIX: Jangan masukkan objek file mentah ke array data
        $data = $request->except(['image']);
        $data['user_id'] = $user->id;
        $data['status_jual'] = 'Aktif'; // Default langsung aktif

        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $filename = time() . '_' . $file->getClientOriginalName();
            $file->move(base_path('public/storage'), $filename);
            $data['gambar_url'] = $filename; 
        }

        $produk = Produk::create($data);

        return response()->json($produk, 201);
    }

    public function update(Request $request, $id): JsonResponse
    {
        $user = Auth::user();
        $produk = Produk::find($id);
        
        if (!$produk) return response()->json(['message' => 'Not found'], 404);

        if ($user->role !== 'admin' && $produk->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Validasi sederhana
        $this->validate($request, [
            'nama_produk' => 'string',
            'harga'       => 'numeric|min:0',
            'stok'        => 'integer|min:0',
            'image'       => 'nullable|image|max:2048'
        ]);

        $data = $request->except(['image']);

        if ($request->hasFile('image')) {
            // Hapus gambar lama
            if ($produk->gambar_url && file_exists(base_path('public/storage/' . $produk->gambar_url))) {
                @unlink(base_path('public/storage/' . $produk->gambar_url));
            }

            $file = $request->file('image');
            $filename = time() . '_' . $file->getClientOriginalName();
            $file->move(base_path('public/storage'), $filename);
            $data['gambar_url'] = $filename;
        }

        $produk->update($data);

        return response()->json($produk);
    }

    public function destroy($id): JsonResponse
    {
        $user = Auth::user();
        $produk = Produk::find($id);

        if (!$produk) return response()->json(['message' => 'Not found'], 404);

        if ($user->role !== 'admin' && $produk->user_id !== $user->id) {
             return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($produk->gambar_url && file_exists(base_path('public/storage/' . $produk->gambar_url))) {
            @unlink(base_path('public/storage/' . $produk->gambar_url));
        }

        $produk->delete();

        return response()->json(['message' => 'Produk berhasil dihapus']);
    }
}