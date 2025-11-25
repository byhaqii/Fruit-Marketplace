<?php

namespace App\Http\Controllers;

use App\Models\Transaksi;
use App\Models\OrderItem;
use App\Models\Produk;
use App\Models\Notification; // <--- PENTING: Untuk notifikasi
use App\Models\User;         // <--- PENTING: Untuk update saldo user
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
        // Admin melihat semua transaksi
        $transaksi = Transaksi::with('user', 'items', 'items.produk')
            ->latest()
            ->get();
        return response()->json($transaksi);
    }

    public function show($id)
    {
        $transaksi = Transaksi::with('user', 'items', 'items.produk')->find($id);
        
        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }
        
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
        // Validasi Input
        $validator = Validator::make($request->all(), [
            'payment_method'    => 'required|string',
            'alamat_pengiriman' => 'required|string',
            'items'             => 'required|array|min:1',
            'items.*.produk_id' => 'required|integer|exists:produk,id',
            'items.*.jumlah'    => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        DB::beginTransaction();
        try {
            $calculatedTotal = 0;
            $itemsToInsert = [];
            $sellersToNotify = []; // Array untuk menampung ID penjual unik

            // 1. Validasi Stok & Hitung Harga
            foreach ($request->items as $itemRequest) {
                $produk = Produk::find($itemRequest['produk_id']);
                
                // Cek Stok
                if ($produk->stok < $itemRequest['jumlah']) {
                    throw new \Exception("Stok '{$produk->nama_produk}' habis.");
                }

                // Hitung Subtotal
                $subtotal = $produk->harga * $itemRequest['jumlah'];
                $calculatedTotal += $subtotal;

                // Kurangi Stok Produk
                $produk->decrement('stok', $itemRequest['jumlah']);

                // Catat Penjual untuk dikirim notifikasi nanti
                $sellersToNotify[$produk->user_id] = true; 

                $itemsToInsert[] = [
                    'produk_id' => $produk->id,
                    'jumlah' => $itemRequest['jumlah'],
                    'harga_saat_beli' => $produk->harga,
                ];
            }

            // 2. Buat Transaksi
            $transaksi = Transaksi::create([
                'user_id'           => Auth::id(),
                'order_id'          => 'INV-' . strtoupper(Str::random(8)),
                'total_harga'       => $calculatedTotal,
                'order_status'      => 'menunggu konfirmasi',
                'payment_method'    => $request->payment_method,
                'payment_status'    => 'pending',
                'alamat_pengiriman' => $request->alamat_pengiriman,
            ]);

            // 3. Buat Order Items
            foreach ($itemsToInsert as $dataItem) {
                OrderItem::create(array_merge($dataItem, ['transaksi_id' => $transaksi->id]));
            }

            // 4. Kirim Notifikasi ke Penjual
            foreach (array_keys($sellersToNotify) as $sellerId) {
                // Pastikan Model Notification sudah dibuat & dimigrasi
                if (class_exists(Notification::class)) {
                    Notification::create([
                        'user_id' => $sellerId,
                        'title' => 'Pesanan Baru Masuk!',
                        'body' => "Pesanan #{$transaksi->order_id} menunggu konfirmasi Anda.",
                        'type' => 'order',
                        'related_id' => $transaksi->id
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                'message' => 'Transaksi berhasil dibuat.',
                'data' => $transaksi->load('items'),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Gagal membuat transaksi.',
                'error' => $e->getMessage()
            ], 500);
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

        // Query: Ambil Transaksi Dimana item-itemnya punya produk yg user_id nya sama dengan penjual
        $transaksi = Transaksi::whereHas('items.produk', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->with(['user', 'items.produk']) 
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
            'status' => 'required|string|in:Diproses,Dikirim,Dibatalkan'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $transaksi = Transaksi::with('items.produk')->find($id);

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

        // Update status
        $transaksi->order_status = $newStatus;
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
        // Load detail sampai ke user pemilik produk (penjual)
        $transaksi = Transaksi::with('items.produk.user')->find($id);
        
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
                    
                    // Tambah Saldo Penjual
                    $penjual->saldo = $penjual->saldo + $subtotal;
                    $penjual->save();

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