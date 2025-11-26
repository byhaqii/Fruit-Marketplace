<?php

namespace App\Http\Controllers;

use App\Models\Transaksi;
use App\Models\OrderItem;
use App\Models\Produk;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class TransaksiController extends Controller
{
    // =================================================================
    // 1. FITUR UMUM & ADMIN
    // =================================================================

    public function index()
    {
        // PERBAIKAN: Menggunakan 'orderItems' sesuai nama fungsi di Model Transaksi.php
        $transaksi = Transaksi::with(['user', 'orderItems.produk'])->latest()->get();
        return response()->json($transaksi);
    }

    public function show($id)
    {
        // PERBAIKAN: Menggunakan 'orderItems'
      $transaksi = Transaksi::with(['user', 'orderItems.produk'])->find($id);
        if (!$transaksi) return response()->json(['message' => 'Not Found'], 404);

        $user = Auth::user();
        $isAllowed = false;

        // Akses dibolehkan jika: Admin ATAU Pemilik Pesanan
        if ($user->role === 'admin' || $transaksi->user_id === $user->id) {
            $isAllowed = true;
        } else {
            // Cek jika user adalah PENJUAL yang barangnya ada di transaksi ini
            foreach ($transaksi->orderItems as $item) {
                if ($item->produk && $item->produk->user_id == $user->id) {
                    $isAllowed = true;
                    break;
                }
            }
        }

        if (!$isAllowed) {
            return response()->json(['message' => 'Tidak diizinkan'], 403);
        }
        
        return response()->json($transaksi);
    }

    // =================================================================
    // 2. FITUR PEMBELI (BUYER)
    // =================================================================

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'payment_method'    => 'required|string',
            'alamat_pengiriman' => 'required|string',
            'items'             => 'required|array|min:1',
            'items.*.produk_id' => 'required|integer|exists:produk,id',
            'items.*.jumlah'    => 'required|integer|min:1',
        ]);

        if ($validator->fails()) return response()->json($validator->errors(), 422);

        DB::beginTransaction();
        try {
            $groupedItems = [];
            
            // Grouping berdasarkan Penjual
            foreach ($request->items as $itemReq) {
                $produk = Produk::find($itemReq['produk_id']);
                if ($produk->stok < $itemReq['jumlah']) {
                    throw new \Exception("Stok {$produk->nama_produk} kurang.");
                }
                $groupedItems[$produk->user_id][] = ['produk' => $produk, 'qty' => $itemReq['jumlah']];
            }

            $createdTransactions = [];

            foreach ($groupedItems as $sellerId => $items) {
                $subtotal = 0;
                foreach ($items as $d) $subtotal += $d['produk']->harga * $d['qty'];
                
                $ongkir = 10000; 
                $transaksi = Transaksi::create([
                    'user_id'           => Auth::id(),
                    'order_id'          => 'INV-' . time() . '-' . Str::random(4),
                    'total_harga'       => $subtotal + $ongkir,
                    'ongkos_kirim'      => $ongkir,
                    'order_status'      => 'menunggu konfirmasi',
                    'payment_method'    => $request->payment_method,
                    'payment_status'    => 'pending',
                    'alamat_pengiriman' => $request->alamat_pengiriman,
                ]);

                foreach ($items as $d) {
                    OrderItem::create([
                        'transaksi_id' => $transaksi->id,
                        'produk_id'    => $d['produk']->id,
                        'jumlah'       => $d['qty'],
                        'harga_saat_beli' => $d['produk']->harga,
                    ]);
                    $d['produk']->decrement('stok', $d['qty']);
                }

                // [LOG ACTIVITY] Notifikasi ke Penjual
                Notification::create([
                    'user_id'    => $sellerId,
                    'title'      => 'Pesanan Masuk',
                    'body'       => "Anda menerima pesanan baru #{$transaksi->order_id}",
                    'type'       => 'order',
                    'related_id' => $transaksi->id
                ]);

                $createdTransactions[] = $transaksi;
            }

            DB::commit();
            return response()->json(['message' => 'Checkout berhasil', 'data' => $createdTransactions], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Gagal transaksi', 'error' => $e->getMessage()], 500);
        }
    }

    // =================================================================
    // 3. FITUR PENJUAL (SELLER)
    // =================================================================

    /**
     * Mengambil daftar transaksi yang berisi produk milik penjual yang sedang login.
     */
    public function getSellerTransactions(Request $request)
    {
        $user = Auth::user();

        // PERBAIKAN: Menggunakan 'orderItems'
        $transaksi = Transaksi::whereHas('orderItems.produk', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->with(['user', 'orderItems.produk']) 
        ->latest()
        ->get();

        return response()->json($transaksi);
    }

    /**
     * Penjual mengupdate status pesanan (Diproses / Dikirim / Dibatalkan)
     */
    public function updateStatusBySeller(Request $request, $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|string|in:Diproses,Dikirim,Dibatalkan',
            'nomor_resi' => 'nullable|string' // Resi opsional/wajib tergantung status
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // PERBAIKAN: Menggunakan 'orderItems'
        $transaksi = Transaksi::with('orderItems.produk')->find($id);

        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }

        $user = Auth::user();
        $newStatus = $request->status;

        // Validasi Hak Akses Penjual
        if ($user->role !== 'admin') {
            $isSellerOfThisOrder = false;
            foreach ($transaksi->orderItems as $item) {
                if ($item->produk && $item->produk->user_id == $user->id) {
                    $isSellerOfThisOrder = true;
                    break;
                }
            }
            if (!$isSellerOfThisOrder) {
                return response()->json(['message' => 'Anda bukan penjual produk di pesanan ini'], 403);
            }
        }

        // Logika Urutan Status
        if ($newStatus === 'Diproses' && $transaksi->order_status !== 'menunggu konfirmasi') {
            return response()->json(['message' => 'Pesanan tidak bisa diproses (Status saat ini: ' . $transaksi->order_status . ')'], 422);
        }

        if ($newStatus === 'Dikirim' && $transaksi->order_status !== 'Diproses') {
            return response()->json(['message' => 'Pesanan belum diproses, tidak bisa langsung dikirim'], 422);
        }

        // Update status & Resi
        $transaksi->order_status = $newStatus;
        if ($request->has('nomor_resi') && $newStatus === 'Dikirim') {
            $transaksi->nomor_resi = $request->nomor_resi;
        }
        $transaksi->save();

        // Kirim Notifikasi ke Pembeli
        if (class_exists(Notification::class)) {
            Notification::create([
                'user_id' => $transaksi->user_id, // ID Pembeli
                'title' => 'Update Pesanan',
                'body' => "Pesanan #{$transaksi->order_id} statusnya sekarang: {$request->status}",
                'type' => 'info',
                'related_id' => $transaksi->id
            ]);
        }

        return response()->json([
            'message' => 'Status transaksi berhasil diperbarui menjadi: ' . $newStatus,
            'data' => $transaksi
        ]);
    }

    // ================================================================
    // 4. TERIMA BARANG: Saldo & Notifikasi Uang Masuk
    // ================================================================
    public function markAsReceived(Request $request, $id): JsonResponse
    {
        // PERBAIKAN: Menggunakan 'orderItems'
        $transaksi = Transaksi::with('orderItems.produk.user')->find($id);
        
        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }

        if ($transaksi->user_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Hanya bisa diterima jika status 'Dikirim' atau 'Tiba di tujuan'
        if (!in_array($transaksi->order_status, ['Dikirim', 'Tiba di tujuan'])) {
            return response()->json(['message' => 'Pesanan belum bisa diselesaikan'], 422);
        }

        DB::beginTransaction();
        try {
            // 1. Update Status Transaksi
            $transaksi->order_status = 'Selesai';
            $transaksi->payment_status = 'paid';
            $transaksi->save();

            // 2. Distribusi Saldo ke Penjual
            foreach ($transaksi->orderItems as $item) {
                $produk = $item->produk;
                if ($produk && $produk->user) {
                    $penjual = $produk->user;
                    
                    // Hitung total uang untuk produk ini
                    $subtotal = $item->harga_saat_beli * $item->jumlah;
                    
                    // Tambah Saldo Penjual (Atomic Update agar aman)
                    // Menggantikan $penjual->saldo = ... + ...
                    $penjual->increment('saldo', $subtotal);

                    // 3. Kirim Notifikasi Dana Masuk
                    if (class_exists(Notification::class)) {
                        Notification::create([
                            'user_id' => $penjual->id,
                            'title' => 'Dana Masuk',
                            'body' => "Pesanan #{$transaksi->order_id} selesai. Rp " . number_format($subtotal, 0, ',', '.') . " masuk ke saldo.",
                            'type' => 'info',
                            'related_id' => $transaksi->id
                        ]);
                    }
                }
            }

            DB::commit();
            return response()->json(['message' => 'Pesanan diterima', 'data' => $transaksi]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Error', 'error' => $e->getMessage()], 500);
        }
    }

    public function cancelOrder(Request $request, $id): JsonResponse
    {
        $transaksi = Transaksi::find($id);
        if (!$transaksi) return response()->json(['message' => 'Not Found'], 404);

        if ($transaksi->user_id !== Auth::id() && Auth::user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($transaksi->order_status !== 'menunggu konfirmasi') {
            return response()->json(['message' => 'Pesanan sudah diproses, tidak bisa dibatalkan'], 422);
        }

        $transaksi->order_status = 'Dibatalkan';
        $transaksi->save();

        return response()->json(['message' => 'Transaksi dibatalkan', 'data' => $transaksi]);
    }
}