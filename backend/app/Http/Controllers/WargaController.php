<?php

namespace App\Http\Controllers;

use App\Models\Warga;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class WargaController extends Controller
{
    /**
     * Menampilkan semua data warga.
     */
    public function index()
    {
        $warga = Warga::all();
        return response()->json($warga);
    }

    /**
     * Menyimpan data warga baru.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|integer|exists:users,id|unique:warga',
            'nik' => 'required|string|max:16|unique:warga',
            'nama_lengkap' => 'required|string|max:255',
            'alamat' => 'required|string',
            'no_hp' => 'required|string|max:15',
            // Tambahkan validasi lain sesuai migration Anda
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $warga = Warga::create($validator->validated());

        return response()->json([
            'message' => 'Data warga berhasil ditambahkan',
            'data' => $warga
        ], 201);
    }

    /**
     * Menampilkan detail satu warga.
     */
    public function show($id)
    {
        $warga = Warga::find($id);

        if (!$warga) {
            return response()->json(['message' => 'Data warga tidak ditemukan'], 404);
        }

        return response()->json($warga);
    }

    /**
     * Memperbarui data warga.
     */
    public function update(Request $request, $id)
    {
        $warga = Warga::find($id);

        if (!$warga) {
            return response()->json(['message' => 'Data warga tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'nik' => 'string|max:16|unique:warga,nik,' . $id,
            'nama_lengkap' => 'string|max:255',
            'alamat' => 'string',
            'no_hp' => 'string|max:15',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $warga->update($validator->validated());

        return response()->json([
            'message' => 'Data warga berhasil diperbarui',
            'data' => $warga
        ]);
    }

    /**
     * Menghapus data warga.
     */
    public function destroy($id)
    {
        $warga = Warga::find($id);

        if (!$warga) {
            return response()->json(['message' => 'Data warga tidak ditemukan'], 404);
        }

        $warga->delete();

        return response()->json(['message' => 'Data warga berhasil dihapus'], 200);
    }
}