<?php

namespace App\Http\Controllers;

use App\Models\Iuran; // <-- Import Model Iuran
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class IuranController extends Controller
{
    /**
     * Memeriksa apakah pengguna yang login adalah Admin.
     */
    private function isAdmin(Request $request): bool
    {
        return $request->user()->role === 'admin';
    }

    /**
     * Menampilkan semua jenis iuran (Hanya Admin).
     * GET /iuran
     */
    public function index(Request $request): JsonResponse
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        $iuran = Iuran::all();
        return response()->json($iuran);
    }

    /**
     * Menampilkan satu jenis iuran (Hanya Admin).
     * GET /iuran/{id}
     */
    public function show(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        $iuran = Iuran::find($id);
        if (!$iuran) {
            return response()->json(['message' => 'Jenis iuran tidak ditemukan'], 404);
        }
        return response()->json($iuran);
    }

    /**
     * Menyimpan jenis iuran baru (Hanya Admin).
     * POST /iuran
     */
    public function store(Request $request): JsonResponse
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        // Validasi berdasarkan migrasi Iuran
        try {
            $this->validate($request, [
                'nama_iuran' => 'required|string|max:255|unique:iuran,nama_iuran',
                'deskripsi' => 'nullable|string',
                'jumlah' => 'required|numeric|min:0',
                'periode' => 'required|in:Bulanan,Tahunan,Satu Kali', // Sesuai migrasi
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        $iuran = Iuran::create($request->all());

        return response()->json($iuran, 201); // 201 Created
    }

    /**
     * Memperbarui jenis iuran (Hanya Admin).
     * POST /iuran/{id}
     */
    public function update(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        $iuran = Iuran::find($id);
        if (!$iuran) {
            return response()->json(['message' => 'Jenis iuran tidak ditemukan'], 404);
        }

        try {
            $this->validate($request, [
                'nama_iuran' => 'string|max:255|unique:iuran,nama_iuran,'.$id, // Unik, kecuali ID ini
                'jumlah' => 'numeric|min:0',
                'periode' => 'in:Bulanan,Tahunan,Satu Kali',
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        $iuran->fill($request->only(['nama_iuran', 'deskripsi', 'jumlah', 'periode', 'is_aktif']));
        $iuran->save();

        return response()->json($iuran);
    }

    /**
     * Menghapus jenis iuran (Hanya Admin).
     * DELETE /iuran/{id}
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        $iuran = Iuran::find($id);
        if (!$iuran) {
            return response()->json(['message' => 'Jenis iuran tidak ditemukan'], 404);
        }

        // TODO: Tambahkan pengecekan apakah iuran ini sudah pernah dipakai di tabel 'transaksi'
        // Jika sudah, sebaiknya jangan dihapus, tapi di-nonaktifkan (set 'is_aktif' = false)

        $iuran->delete();

        return response()->json(['message' => 'Jenis iuran berhasil dihapus']);
    }
}