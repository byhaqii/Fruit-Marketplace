<?php

namespace App\Http\Controllers;

use App\Models\Transaksi;
use App\Models\Order_Items; 
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
    // ... method index() ...
    public function index()
    {
        $transaksi = Transaksi::with('user', 'items', 'items.produk')
                        ->latest()
                        ->get();
        return response()->json($transaksi);
    }

    // ... method getUserTransactions() ...
    public function getUserTransactions()
    {
        $userId = Auth::id();
        $transaksi = Transaksi::where('user_id', $userId)
                        ->with('items', 'items.produk') 
                        ->latest()
                        ->get();
        return response()->json($transaksi);
    }

    // ... method store() ...
    public function store(Request $request)
    {
        // ... (Validasi, DB::beginTransaction, dll... sama seperti sebelumnya)
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
                'order_status'      => 'menunggu konfirmasi',
                'payment_method'    => $request->payment_method,
                'payment_status'    => 'pending',
                'alamat_pengiriman' => $request->alamat_pengiriman,
            ]);

            foreach ($request->items as $item) {
                Order_Items::create([
                    'transaksi_id'    => $transaksi->id,
                    'produk_id'       => $item['produk_id'],
                    'jumlah'          => $item['jumlah'],
                    'harga_saat_beli' => $item['harga_saat_beli'],
                ]);
            }

           $qrText = "Order ID: " . $transaksi->order_id . "\nTotal Bayar: Rp " . $transaksi->total_harga;

            $qrCodeImage = QrCode::driver('gd')
                                ->format('png')
                                 ->size(250)
                                 ->generate($qrText);
            
            $qrCodeBase64 = 'data:image/png;base64,' . base64_encode($qrCodeImage);

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
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // ... method show() ...
    public function show($id)
    {
        // ... (Kode show Anda yang sudah ada) ...
        $transaksi = Transaksi::with('user', 'items', 'items.produk')->find($id);
        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }
        if ($transaksi->user_id !== Auth::id() && Auth::user()->role !== 'admin') {
            return response()->json(['message' => 'Tidak diizinkan'], 403);
        }
        return response()->json($transaksi);
    }


    /**
     * [BARU] Update status pesanan oleh Penjual atau Admin.
     */
    public function updateStatusBySeller(Request $request, $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|string|in:Diproses,Dikirim'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // --- PERBAIKAN LINTER DI SINI ---
        /** @var \App\Models\Transaksi $transaksi */
        $transaksi = Transaksi::with('items.produk')->find($id);
        // ---------------------------------
        
        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();
        $newStatus = $request->status;

        // Otorisasi: Hanya Admin atau Penjual yang produknya ada di order ini
        if ($user->role !== 'admin') {
            $isSellerOfThisOrder = false;
            
            // --- PERBAIKAN LINTER (Opsional, tapi bagus) ---
            /** @var \App\Models\Order_Items $item */
            foreach ($transaksi->items as $item) { // Baris ini sekarang aman
            // ---------------------------------------------
                if ($item->produk && $item->produk->user_id == $user->id) {
                    $isSellerOfThisOrder = true;
                    break;
                }
            }
            if (!$isSellerOfThisOrder) {
                return response()->json(['message' => 'Anda tidak memiliki hak akses untuk transaksi ini'], 403);
            }
        }

        // Validasi Alur Kerja (Workflow)
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

    /**
     * [BARU] Pembeli membatalkan pesanan.
     */
    public function cancelOrder(Request $request, $id): JsonResponse
    {
        /** @var \App\Models\Transaksi $transaksi */
        $transaksi = Transaksi::find($id);
        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }

        if ($transaksi->user_id !== Auth::id()) {
            return response()->json(['message' => 'Anda tidak memiliki hak akses untuk transaksi ini'], 403);
        }

        if ($transaksi->order_status !== 'menunggu konfirmasi') {
            return response()->json(['message' => 'Pesanan tidak dapat dibatalkan karena sudah diproses oleh penjual.'], 422);
        }

        $transaksi->order_status = 'Cancel';
        $transaksi->save();

        return response()->json([
            'message' => 'Transaksi berhasil dibatalkan.',
            'data' => $transaksi
        ]);
    }

    /**
     * [BARU] Pembeli mengonfirmasi pesanan telah tiba.
     */
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

        $transaksi->order_status = 'Tiba di tujuan';
        $transaksi->payment_status = 'paid';
        $transaksi->save();

        return response()->json([
            'message' => 'Pesanan telah diterima. Transaksi selesai.',
            'data' => $transaksi
        ]);
    }
}