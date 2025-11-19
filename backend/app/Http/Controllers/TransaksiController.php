<?php

namespace App\Http\Controllers;

use App\Models\Transaksi;
use App\Models\OrderItem;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use SimpleSoftwareIO\QrCode\Facades\QrCode;
use Illuminate\Support\Str;

class TransaksiController extends Controller
{
    public function index()
    {
        $transaksi = Transaksi::with('user', 'items', 'items.produk')
            ->latest()
            ->get();
        return response()->json($transaksi);
    }

    public function getUserTransactions()
    {
        $userId = Auth::id();
        $transaksi = Transaksi::where('user_id', $userId)
            ->with('items', 'items.produk')
            ->latest()
            ->get();
        return response()->json($transaksi);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'total_harga'       => 'required|numeric|min:0',
            'payment_method'    => 'required|string',
            'alamat_pengiriman' => 'required|string',
            'items'             => 'required|array|min:1',
            'items.*.produk_id' => 'required|integer|exists:produk,id',
            'items.*.jumlah'    => 'required|integer|min:1',
            'items.*.harga_saat_beli' => 'required|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        DB::beginTransaction();
        try {
            $transaksi = Transaksi::create([
                'user_id'           => Auth::id(),
                'order_id'          => 'INV-' . strtoupper(Str::random(8)),
                'total_harga'       => $request->total_harga,
                'order_status'      => 'menunggu konfirmasi', // Default awal
                'payment_method'    => $request->payment_method,
                'payment_status'    => 'pending',
                'alamat_pengiriman' => $request->alamat_pengiriman,
            ]);

            foreach ($request->items as $item) {
                OrderItem::create([
                    'transaksi_id'    => $transaksi->id,
                    'produk_id'       => $item['produk_id'],
                    'jumlah'          => $item['jumlah'],
                    'harga_saat_beli' => $item['harga_saat_beli'],
                ]);
            }

            // QR Code dinonaktifkan sementara untuk mencegah error 500
            $qrCodeBase64 = null;

            DB::commit();

            return response()->json([
                'message' => 'Transaksi berhasil dibuat, silakan lakukan pembayaran.',
                'data' => $transaksi->load('items'),
                'payment_qr_code' => $qrCodeBase64
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Gagal membuat transaksi, terjadi kesalahan server.',
                'error' => $e->getMessage(),
                'file'  => $e->getFile(),
                'line'  => $e->getLine()
            ], 500);
        }
    }

    public function show($id)
    {
        $transaksi = Transaksi::with('user', 'items', 'items.produk')->find($id);
        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }
        if ($transaksi->user_id !== Auth::id() && Auth::user()->role !== 'admin') {
            return response()->json(['message' => 'Tidak diizinkan'], 403);
        }
        return response()->json($transaksi);
    }

    public function updateStatusBySeller(Request $request, $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|string|in:Diproses,Dikirim'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        /** @var \App\Models\Transaksi $transaksi */
        $transaksi = Transaksi::with('items.produk')->find($id);

        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();
        $newStatus = $request->status;

        if ($user->role !== 'admin') {
            $isSellerOfThisOrder = false;

            // Cek apakah user ini adalah penjual salah satu item di order
            foreach ($transaksi->items as $item) {
                if ($item->produk && $item->produk->user_id == $user->id) {
                    $isSellerOfThisOrder = true;
                    break;
                }
            }
            if (!$isSellerOfThisOrder) {
                return response()->json(['message' => 'Anda tidak memiliki hak akses untuk transaksi ini'], 403);
            }
        }

        // Validasi urutan status
        if ($newStatus === 'Diproses' && $transaksi->order_status !== 'menunggu konfirmasi') {
            return response()->json(['message' => 'Pesanan tidak bisa diproses karena status saat ini adalah ' . $transaksi->order_status], 422);
        }

        if ($newStatus === 'Dikirim' && $transaksi->order_status !== 'Diproses') {
            return response()->json(['message' => 'Pesanan tidak bisa dikirim karena status saat ini adalah ' . $transaksi->order_status], 422);
        }

        $transaksi->order_status = $newStatus;
        $transaksi->save();

        return response()->json([
            'message' => 'Status transaksi berhasil diperbarui menjadi: ' . $newStatus,
            'data' => $transaksi
        ]);
    }

    public function cancelOrder(Request $request, $id): JsonResponse
    {
        /** @var \App\Models\Transaksi $transaksi */
        // Kita perlu load items.produk untuk mengecek kepemilikan penjual
        $transaksi = Transaksi::with('items.produk')->find($id);

        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }

        $user = Auth::user();
        $isAllowed = false;

        // 1. Cek apakah yang login adalah PEMBELI (Pembuat Pesanan)
        if ($transaksi->user_id === $user->id) {
            $isAllowed = true;
        }
        // 2. Cek apakah yang login adalah ADMIN
        elseif ($user->role === 'admin') {
            $isAllowed = true;
        }
        // 3. Cek apakah yang login adalah PENJUAL dari produk di pesanan ini
        else {
            foreach ($transaksi->items as $item) {
                if ($item->produk && $item->produk->user_id == $user->id) {
                    $isAllowed = true;
                    break;
                }
            }
        }

        
        if (!$isAllowed) {
            return response()->json(['message' => 'Anda tidak memiliki hak akses untuk membatalkan transaksi ini'], 403);
        }

        
        if ($transaksi->order_status !== 'menunggu konfirmasi') {
            return response()->json(['message' => 'Pesanan tidak dapat dibatalkan karena status saat ini: ' . $transaksi->order_status], 422);
        }

        $transaksi->order_status = 'Cancel';
        $transaksi->save();

        return response()->json([
            'message' => 'Transaksi berhasil dibatalkan.',
            'data' => $transaksi
        ]);
    }

    public function markAsReceived(Request $request, $id): JsonResponse
    {
        /** @var \App\Models\Transaksi $transaksi */
        $transaksi = Transaksi::find($id);
        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }

        if ($transaksi->user_id !== Auth::id()) {
            return response()->json(['message' => 'Anda tidak memiliki hak akses untuk transaksi ini'], 403);
        }

        if ($transaksi->order_status !== 'Dikirim') {
            return response()->json(['message' => 'Pesanan tidak dapat diterima karena statusnya masih ' . $transaksi->order_status], 422);
        }

        $transaksi->order_status = 'Tiba di tujuan'; // Sesuai Migration baru
        $transaksi->payment_status = 'paid';
        $transaksi->save();

        return response()->json([
            'message' => 'Pesanan telah diterima. Transaksi selesai.',
            'data' => $transaksi
        ]);
    }
}
