// lib/providers/marketplace_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import Dio untuk handling request
import '../core/network/api_client.dart';
import '../models/produk_model.dart';
import '../models/transaksi_model.dart';

class MarketplaceProvider with ChangeNotifier {
  final ApiClient apiClient;

  // --- STATE ---
  List<ProdukModel> _products = [];
  // UBAH: Key menggunakan int karena ID produk dari database adalah integer
  Map<int, int> _cartItems = {}; 
  List<TransaksiModel> _transactions = [];
  bool _isLoading = false;

  // Constructor
  MarketplaceProvider({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient() {
    fetchAllData();
  }

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  List<ProdukModel> get products => _products;
  List<TransaksiModel> get transactions => _transactions;

  /// Mengembalikan daftar PRODUK UNIK yang ada di keranjang
  List<ProdukModel> get cartItems {
    return _cartItems.keys.map((productId) {
      return _products.firstWhere(
        (p) => p.id == productId,
        // Fallback dummy jika produk tidak ditemukan (safety)
        orElse: () => const ProdukModel(
            id: -1, userId: 0, namaProduk: 'Unknown', deskripsi: '', 
            harga: 0, stok: 0, imageUrl: '', kategori: '', statusJual: ''),
      );
    }).where((p) => p.id != -1).toList(); // Filter valid products only
  }

  /// Mengembalikan JUMLAH total item
  int get cartItemCount {
    if (_cartItems.isEmpty) return 0;
    return _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
  }

  /// Menghitung total biaya
  int get totalCost {
    int total = 0;
    _cartItems.forEach((productId, quantity) {
      try {
        final product = _products.firstWhere((p) => p.id == productId);
        total += product.harga * quantity; // Gunakan field 'harga' dari ProdukModel
      } catch (e) {
        print("Error: Produk ID $productId tidak ditemukan di list lokal.");
      }
    });
    return total;
  }

  /// Helper format rupiah
  String get formattedTotalCost {
    if (totalCost == 0) return 'Rp 0';
    final s = totalCost.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  // --- METHODS KERANJANG ---

  int getQuantity(ProdukModel produk) {
    return _cartItems[produk.id] ?? 0;
  }

  void incrementQuantity(ProdukModel produk) {
    if (_cartItems.containsKey(produk.id)) {
      _cartItems[produk.id] = _cartItems[produk.id]! + 1;
    } else {
      _cartItems[produk.id] = 1;
    }
    notifyListeners();
  }

  void decrementQuantity(ProdukModel produk) {
    if (_cartItems.containsKey(produk.id)) {
      if (_cartItems[produk.id]! > 1) {
        _cartItems[produk.id] = _cartItems[produk.id]! - 1;
      } else {
        _cartItems.remove(produk.id);
      }
      notifyListeners();
    }
  }

  void removeFromCart(ProdukModel produk) {
    if (_cartItems.containsKey(produk.id)) {
      _cartItems.remove(produk.id);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems = {};
    notifyListeners();
  }

  // --- API CALLS ---

  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners(); // Update UI state loading

    await Future.wait([
      fetchProducts(),
      fetchTransactions(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  /// GET /produk
  Future<void> fetchProducts() async {
    try {
      final resp = await apiClient.get('/produk'); // Sesuai route Laravel
      if (resp is List) {
        _products = resp
            .map((json) => ProdukModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  /// GET /transaksi (History)
  Future<void> fetchTransactions() async {
    try {
      final resp = await apiClient.get('/transaksi'); // Sesuai route Laravel
      if (resp is List) {
        _transactions = resp
            .map((json) => TransaksiModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  /// POST /transaksi/checkout
  Future<bool> checkout(String alamat, String paymentMethod) async {
    try {
      // Siapkan data items sesuai format yang diminta Backend Laravel
      List<Map<String, dynamic>> itemsPayload = [];
      _cartItems.forEach((id, qty) {
        final product = _products.firstWhere((p) => p.id == id);
        itemsPayload.add({
          'produk_id': id,
          'jumlah': qty,
          'harga_saat_beli': product.harga,
        });
      });

      final payload = {
        'total_harga': totalCost,
        'payment_method': paymentMethod,
        'alamat_pengiriman': alamat,
        'items': itemsPayload,
      };

      await apiClient.post('/transaksi/checkout', payload);
      
      // Jika sukses, bersihkan keranjang dan refresh data transaksi
      clearCart();
      await fetchTransactions();
      return true;

    } catch (e) {
      print("Checkout error: $e");
      return false;
    }
  }

  /// PUT /transaksi/{id}/cancel
  Future<bool> cancelOrder(int id) async {
    try {
      // Akses DIO langsung atau gunakan helper jika ada
      // Karena ApiClient.put belum ada di file yang Anda kirim, 
      // kita pakai dio instance dari apiClient
      final options = await apiClient.optionsWithAuth();
      await apiClient.dio.put('/transaksi/$id/cancel', options: options);
      
      await fetchTransactions(); // Refresh data
      return true;
    } catch (e) {
      print("Error canceling order: $e");
      return false;
    }
  }

  /// PUT /transaksi/{id}/terima
  Future<bool> markAsReceived(int id) async {
    try {
      final options = await apiClient.optionsWithAuth();
      await apiClient.dio.put('/transaksi/$id/terima', options: options);
      
      await fetchTransactions(); // Refresh data
      return true;
    } catch (e) {
      print("Error completing order: $e");
      return false;
    }
  }
}