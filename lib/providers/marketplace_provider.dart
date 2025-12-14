import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/produk_model.dart';
import '../models/transaksi_model.dart';
import '../utils/logger.dart'; // Pastikan Logger diimpor

class MarketplaceProvider with ChangeNotifier {
  final ApiClient apiClient;

  // --- STATE ---
  List<ProdukModel> _allProducts = []; // Data lengkap dari API (Sumber utama)
  List<ProdukModel> _filteredProducts =
      []; // Data yang ditampilkan di UI (Hasil filter)
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
  List<ProdukModel> get products => _filteredProducts;
  List<ProdukModel> get allProducts => _allProducts;
  List<TransaksiModel> get transactions => _transactions;

  // Mengembalikan daftar PRODUK UNIK yang ada di keranjang
  List<ProdukModel> get cartItems {
    return _cartItems.keys
        .map((productId) {
          // Selalu cari produk dari _allProducts (list lengkap)
          return _allProducts.firstWhere(
            (p) => p.id == productId,
            orElse: () => const ProdukModel(
              id: -1,
              userId: 0,
              namaProduk: 'Unknown',
              deskripsi: '',
              harga: 0,
              stok: 0,
              imageUrl: '',
              kategori: '',
              statusJual: '',
            ),
          );
        })
        .where((p) => p.id != -1)
        .toList();
  }

  // Mengembalikan JUMLAH total item
  int get cartItemCount {
    if (_cartItems.isEmpty) return 0;
    return _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
  }

  // Menghitung total biaya
  int get totalCost {
    int total = 0;
    _cartItems.forEach((productId, quantity) {
      try {
        // Selalu cari produk dari _allProducts (list lengkap)
        final product = _allProducts.firstWhere((p) => p.id == productId);
        total += product.harga * quantity;
      } catch (e) {
        print("Error: Produk ID $productId tidak ditemukan di list lokal.");
      }
    });
    return total;
  }

  // Helper format rupiah
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

  // --- FITUR FILTERING ---

  /// Remove vowels to create a phonetic signature
  String _removeVowels(String text) {
    return text.replaceAll(RegExp('[aeiou]'), '');
  }

  /// Calculate Levenshtein distance for similarity matching
  int _levenshteinDistance(String s1, String s2) {
    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<List<int>> distances = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) distances[i][0] = i;
    for (int j = 0; j <= s2.length; j++) distances[0][j] = j;

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        distances[i][j] = [
          distances[i - 1][j] + 1,
          distances[i][j - 1] + 1,
          distances[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return distances[s1.length][s2.length];
  }

  /// Fuzzy matching untuk mencari produk dengan query yang fleksibel
  bool _fuzzyMatch(String text, String query) {
    int queryIndex = 0;
    for (int i = 0; i < text.length && queryIndex < query.length; i++) {
      if (text[i] == query[queryIndex]) {
        queryIndex++;
      }
    }
    return queryIndex == query.length;
  }

  /// Memfilter produk yang ditampilkan berdasarkan query pencarian dengan fuzzy matching.
  void filterProducts(String query) {
    final lowerCaseQuery = query.toLowerCase().trim();
    Logger.log('MarketplaceProvider', 'Filtering products with query: $query');

    if (lowerCaseQuery.isEmpty) {
      _filteredProducts = _allProducts;
    } else {
      _filteredProducts = _allProducts.where((produk) {
        final name = produk.namaProduk.toLowerCase();
        final category = produk.kategori.toLowerCase();

        // 1. Exact substring match (highest priority)
        if (name.contains(lowerCaseQuery) ||
            category.contains(lowerCaseQuery)) {
          return true;
        }

        // 2. Check each word in product name and category
        final nameWords = name.split(RegExp(r'\s+'));
        final categoryWords = category.split(RegExp(r'\s+'));

        for (var word in nameWords) {
          // Word contains query as substring
          if (word.contains(lowerCaseQuery)) return true;

          // Similar words using Levenshtein distance (only for similar length)
          int distance = _levenshteinDistance(word, lowerCaseQuery);
          int maxDistance = ((lowerCaseQuery.length + word.length) / 4).ceil();
          if (distance <= maxDistance && distance <= 2) return true;

          // Phonetic match (remove vowels)
          if (_removeVowels(word) == _removeVowels(lowerCaseQuery) &&
              lowerCaseQuery.length >= 3)
            return true;
        }

        for (var word in categoryWords) {
          if (word.contains(lowerCaseQuery)) return true;

          int distance = _levenshteinDistance(word, lowerCaseQuery);
          int maxDistance = ((lowerCaseQuery.length + word.length) / 4).ceil();
          if (distance <= maxDistance && distance <= 2) return true;

          if (_removeVowels(word) == _removeVowels(lowerCaseQuery) &&
              lowerCaseQuery.length >= 3)
            return true;
        }

        return false;
      }).toList();
    }
    notifyListeners();
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

  // --- API CALLS UMUM ---

  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([fetchProducts(), fetchTransactions()]);

    _isLoading = false;
    notifyListeners();
  }

  /// GET /produk
  Future<void> fetchProducts() async {
    try {
      final resp = await apiClient.get('/produk');
      if (resp is List) {
        final fetchedProducts = resp
            .map((json) => ProdukModel.fromJson(json as Map<String, dynamic>))
            .toList();

        _allProducts = fetchedProducts;
        _filteredProducts = fetchedProducts; // Inisialisasi list tampilan
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  /// GET /transaksi (History)
  // FIX: Dibuat lebih robust untuk penanganan error API
  Future<void> fetchTransactions() async {
    try {
      final resp = await apiClient.get('/transaksi');

      if (resp is List) {
        _transactions = resp
            .map(
              (json) => TransaksiModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        _transactions = [];
      }
    } on DioException catch (e) {
      print(
        'Dio Error fetching transactions: ${e.response?.data ?? e.message}',
      );
      _transactions = [];
    } catch (e) {
      print('General Error fetching transactions: $e');
      _transactions = [];
    }
  }

  /// GET /transaksi/masuk (Seller incoming orders)
  Future<void> fetchSellerTransactions() async {
    try {
      final options = await apiClient.optionsWithAuth();
      final resp = await apiClient.dio.get(
        '/transaksi/masuk',
        options: options,
      );

      final data = resp.data;
      if (data is List) {
        _transactions = data
            .map(
              (json) => TransaksiModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        _transactions = [];
      }
      // Fallback: if empty, also load user transactions so page isn't blank
      if (_transactions.isEmpty) {
        await fetchTransactions();
      }
    } on DioException catch (e) {
      print(
        'Dio Error fetching seller transactions: ${e.response?.data ?? e.message}',
      );
      _transactions = [];
    } catch (e) {
      print('General Error fetching seller transactions: $e');
      _transactions = [];
    }
  }

  // --- FITUR PEMBELI ---

  /// POST /transaksi/checkout
  Future<bool> checkout(String alamat, String paymentMethod) async {
    try {
      List<Map<String, dynamic>> itemsPayload = [];

      _cartItems.forEach((id, qty) {
        final productIndex = _allProducts.indexWhere((p) => p.id == id);

        if (productIndex != -1) {
          final product = _allProducts[productIndex];
          itemsPayload.add({
            'produk_id': id,
            'jumlah': qty,
            'harga_saat_beli': product.harga,
          });
        } else {
          print(
            'Warning: Produk ID $id di keranjang tidak ditemukan saat checkout.',
          );
        }
      });

      if (itemsPayload.isEmpty) {
        return false;
      }

      final payload = {
        'total_harga': totalCost,
        'payment_method': paymentMethod,
        'alamat_pengiriman': alamat,
        'items': itemsPayload,
      };

      await apiClient.post('/transaksi/checkout', payload);

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
      final options = await apiClient.optionsWithAuth();
      await apiClient.dio.put('/transaksi/$id/cancel', options: options);

      await fetchTransactions();
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

      await fetchTransactions();
      return true;
    } catch (e) {
      print("Error completing order: $e");
      return false;
    }
  }

  /// Getter untuk fitur "Beli Lagi"
  List<ProdukModel> get buyAgainList {
    final Set<int> addedIds = {};
    final List<ProdukModel> results = [];

    for (var trans in _transactions) {
      for (var item in trans.items) {
        if (!addedIds.contains(item.id)) {
          addedIds.add(item.id);
          results.add(item);
        }
      }
    }
    return results.take(10).toList();
  }

  // --- FITUR PENJUAL ---

  /// POST /produk (Tambah Produk)
  Future<bool> addProduct({
    required String nama,
    required String deskripsi,
    required int harga,
    required int stok,
    required String kategori,
    required String imagePath,
  }) async {
    try {
      String fileName = imagePath.split('/').last;
      FormData formData = FormData.fromMap({
        'nama_produk': nama,
        'deskripsi': deskripsi,
        'harga': harga,
        'stok': stok,
        'kategori': kategori,
        'image': await MultipartFile.fromFile(imagePath, filename: fileName),
      });

      // Kirim dengan header auth eksplisit agar user_id terekam (role penjual/admin)
      final options = await apiClient.optionsWithAuth();
      await apiClient.post('/produk', formData, options: options);
      await fetchProducts();
      return true;
    } catch (e) {
      print("Gagal tambah produk: $e");
      return false;
    }
  }

  /// PUT /produk/{id} (Edit Produk)
  Future<bool> updateProduct({
    required int id,
    required String nama,
    required String deskripsi,
    required int harga,
    required int stok,
    required String kategori,
    String? imagePath,
  }) async {
    try {
      final options = await apiClient.optionsWithAuth();

      Map<String, dynamic> dataMap = {
        'nama_produk': nama,
        'deskripsi': deskripsi,
        'harga': harga,
        'stok': stok,
        'kategori': kategori,
        // PENTING: Method Spoofing agar PHP mengenali ini sebagai PUT
        '_method': 'PUT',
      };

      if (imagePath != null) {
        String fileName = imagePath.split('/').last;
        dataMap['image'] = await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        );
      }

      FormData formData = FormData.fromMap(dataMap);

      // PENTING: Gunakan POST, bukan PUT. Backend akan membacanya sebagai PUT karena ada _method
      await apiClient.post('/produk/$id', formData, options: options);

      await fetchProducts();
      return true;
    } catch (e) {
      if (e is DioException) {
        print("Error Update: ${e.response?.data}");
      } else {
        print("Gagal update produk: $e");
      }
      return false;
    }
  }

  /// DELETE /produk/{id} (Hapus Produk)
  Future<bool> deleteProduct(int id) async {
    try {
      final options = await apiClient.optionsWithAuth();
      await apiClient.dio.delete('/produk/$id', options: options);

      _allProducts.removeWhere((p) => p.id == id);
      _filteredProducts.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print("Gagal hapus produk: $e");
      return false;
    }
  }
  Future<void> fetchSellerTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
        // PERBAIKAN: CALL ENDPOINT KHUSUS UNTUK TRANSAKSI PENJUAL
        final resp = await apiClient.get('/transaksi/masuk'); 
        
        if (resp is List) {
            // UPDATE THE MAIN _transactions LIST
            _transactions = resp
                .map((json) => TransaksiModel.fromJson(json as Map<String, dynamic>))
                .toList();
        } else {
            _transactions = []; 
        }
    } on DioException catch (e) {
        print('Dio Error fetching seller transactions: ${e.response?.data ?? e.message}');
        _transactions = []; 
    } catch (e) {
        print('General Error fetching seller transactions: $e');
        _transactions = [];
    }
    _isLoading = false;
    notifyListeners();
}

  /// PUT /transaksi/{id}/update-status (Penjual Update Status)
  Future<bool> updateOrderStatus(int id, String status) async {
    try {
      // Pastikan ada validasi dan kirim data kurir/resi jika statusnya Dikirim
      final options = await apiClient.optionsWithAuth();
      
      // Catatan: Jika status 'Dikirim', tambahkan data resi/kurir di sini. 
      // Karena kode ini tidak disediakan, kita asumsikan data yang dikirim sudah benar.
      
      await apiClient.dio.put(
        '/transaksi/$id/update-status',
        data: {'status': status},
        options: options,
      );
      // Refresh seller-specific transactions so the page updates immediately
      await fetchSellerTransactions();
      return true;
    } catch (e) {
      // Bubble up DioException so UI can show server message (e.g., 422)
      if (e is DioException) {
        throw e;
      }
      print("Gagal update status pesanan: $e");
      return false;
    }
  }

  /// Get Pesanan Masuk (Yang belum selesai)
  List<TransaksiModel> get incomingOrders {
    return _transactions
        .where(
          (t) =>
              t.status != 'Selesai' &&
              t.status != 'Cancel' &&
              t.status != 'Tiba di tujuan',
        )
        .toList();
  }
}
