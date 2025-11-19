import 'package:flutter/material.dart';
import '../core/network/api_client.dart'; 
import '../models/produk_model.dart'; 
import '../models/transaksi_model.dart'; // <-- 1. TAMBAHKAN IMPORT

class MarketplaceProvider with ChangeNotifier {
  final ApiClient apiClient;

  // --- STATE ---
  List<ProdukModel> _products = [];
  Map<String, int> _cartItems = {};
  List<TransaksiModel> _transactions = []; // <-- 2. TAMBAHKAN STATE TRANSAKSI
  bool _isLoading = false;

  // Constructor: Panggil API saat provider dibuat
  MarketplaceProvider({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient() {
    // 4. UBAH CONSTRUCTOR: Panggil fungsi baru
    fetchAllData();
  }

  // --- GETTERS (Untuk dibaca oleh UI) ---

  bool get isLoading => _isLoading;
  List<ProdukModel> get products => _products;
  List<TransaksiModel> get transactions => _transactions; // <-- 3. TAMBAHKAN GETTER

  /// Mengembalikan daftar PRODUK UNIK yang ada di keranjang
  List<ProdukModel> get cartItems {
    return _cartItems.keys.map((productId) {
      return _products.firstWhere(
        (p) => p.id == productId,
      );
    }).toList();
  }

  /// Mengembalikan JUMLAH total item (termasuk kuantitas)
  int get cartItemCount {
    if (_cartItems.isEmpty) return 0;
    return _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
  }

  /// Menghitung total biaya dari item di keranjang
  int get totalCost {
    int total = 0;
    _cartItems.forEach((productId, quantity) {
      try {
        final product = _products.firstWhere((p) => p.id == productId);
        total += product.price * quantity;
      } catch (e) {
        print("Error: Produk di keranjang (ID: $productId) tidak ditemukan.");
      }
    });
    return total;
  }

  /// Mengembalikan total biaya dalam format "Rp. 50.000"
  String get formattedTotalCost {
    if (totalCost == 0) return 'Rp. 0,-';
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
    return 'Rp. ${buffer.toString().split('').reversed.join()},-';
  }

  // --- METHODS (Untuk dipanggil oleh UI) ---

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

  // --- DATA FETCHING ---

  // 5. BUAT FUNGSI WRAPPER (Pembungkus)
  /// Mengambil semua data yang dibutuhkan provider ini
  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    // Menjalankan kedua fetch secara bersamaan
    await Future.wait([
      fetchProducts(),
      fetchTransactions(),
    ]);

    _isLoading = false;
    notifyListeners(); // Beri tahu UI bahwa semua data sudah siap
  }

  /// Mengambil daftar produk dari API
  Future<void> fetchProducts() async {
    // 6. HAPUS isLoading & notifyListeners (karena di-handle fetchAllData)
    try {
      final resp = await apiClient.get('/products');
      
      if (resp is List) {
        _products = resp
            .map((json) => ProdukModel.fromMap(json as Map<String, dynamic>))
            .toList();
      } else {
        _products = [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      _products = []; 
    }
  }

  // 7. BUAT FUNGSI FETCH TRANSAKSI
  /// Mengambil riwayat transaksi dari API
  Future<void> fetchTransactions() async {
    try {
      // Asumsi endpoint API Anda adalah '/transactions/history'
      final resp = await apiClient.get('/transactions/history');
      
      if (resp is List) {
        _transactions = resp
            .map((json) => TransaksiModel.fromMap(json as Map<String, dynamic>))
            .toList();
      } else {
        _transactions = [];
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      _transactions = []; 
    }
  }
}