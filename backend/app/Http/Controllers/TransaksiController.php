<?php

namespace App\Http\Controllers;

use App\Models\Transaksi;
use App\Models\OrderItem; 
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class TransaksiController extends Controller
{
    /**
     * Menampilkan semua transaksi (Untuk Admin).
     */
    public function index()
    {
        // 'with' akan mengambil data relasi user dan items
        $transaksi = Transaksi::with('user', 'items', 'items.produk')
                        ->latest()
                        ->get();
                        
        return response()->json($transaksi);
    }

    /**
     * Menampilkan transaksi milik user yang sedang login.
     */
    public function getUserTransactions()
    {
        $userId = Auth::id();
        $transaksi = Transaksi::where('user_id', $userId)
                        ->with('items', 'items.produk') // Ambil item dan detail produknya
                        ->latest()
                        ->get();
        
        return response()->json($transaksi);
    }

    /**
     * Logika Checkout BARU (Store)
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'total_harga'       => 'required|numeric|min:0',
            'payment_method'    => 'required|string', // misal: 'manual_transfer'
            'alamat_pengiriman' => 'required|string',
            'items'             => 'required|array|min:1', // Harus ada array 'items'
            'items.*.produk_id' => 'required|integer|exists:produk,id',
            'items.*.jumlah'    => 'required|integer|min:1',
            'items.*.harga_saat_beli' => 'required|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Mulai Database Transaction
        DB::beginTransaction();
        try {
            // 1. Buat Transaksi (Order Header)
            $transaksi = Transaksi::create([
                'user_id'           => Auth::id(),
                'order_id'          => 'INV-' . strtoupper(Str::random(8)), // Buat Order ID unik
                'total_harga'       => $request->total_harga,
                'order_status'      => 'pending',
                'payment_method'    => $request->payment_method,
                'payment_status'    => 'pending',
                'alamat_pengiriman' => $request->alamat_pengiriman,
            ]);

            // 2. Loop dan buat Order Items
            foreach ($request->items as $item) {
                OrderItem::create([
                    'transaksi_id'    => $transaksi->id,
                    'produk_id'       => $item['produk_id'],
                    'jumlah'          => $item['jumlah'],
                    'harga_saat_beli' => $item['harga_saat_beli'],
                ]);

                // Di sini Anda juga harus mengurangi stok produk (opsional tapi disarankan)
                // $produk = Produk::find($item['produk_id']);
                // $produk->stok = $produk->stok - $item['jumlah'];
                // $produk->save();
            }

            // Jika semua berhasil, commit
            DB::commit();

            return response()->json([
                'message' => 'Transaksi berhasil dibuat',
                'data' => $transaksi->load('items') // Kirim kembali data transaksi lengkap
            ], 201);

        } catch (\Exception $e) {
            // Jika ada error, batalkan semua
            DB::rollBack();
            return response()->json([
                'message' => 'Gagal membuat transaksi, terjadi kesalahan server.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Menampilkan detail satu transaksi.
     */
    public function show($id)
    {
        $transaksi = Transaksi::with('user', 'items', 'items.produk')->find($id);

        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }

        // Cek Keamanan: Pastikan hanya pemilik atau admin yang bisa lihat
        if ($transaksi->user_id !== Auth::id() && Auth::user()->role !== 'admin') {
            return response()->json(['message' => 'Tidak diizinkan'], 403);
        }

        return response()->json($transaksi);
    }
}