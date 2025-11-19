// lib/models/transaksi_model.dart

import 'produk_model.dart'; // <--- 1. Pastikan Import ini ada

class TransaksiModel {
  final int id;
  final String title;
  final String date;
  final String price;
  final String status;
  final String imageUrl;
  final List<ProdukModel> items; // <--- 2. Tambahkan Field ini

  const TransaksiModel({
    required this.id,
    required this.title,
    required this.date,
    required this.price,
    required this.status,
    required this.imageUrl,
    required this.items, // <--- 3. Tambahkan di Constructor
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    // Ambil list items dari JSON
    var listItemsJson = json['items'] as List?;
    
    // Parsing list items menjadi List<ProdukModel>
    List<ProdukModel> parsedItems = [];
    if (listItemsJson != null) {
      parsedItems = listItemsJson.map((itemJson) {
        // Pastikan backend mengirim object 'produk' di dalam items
        return ProdukModel.fromJson(itemJson['produk'] ?? {});
      }).toList();
    }

    // Ambil produk pertama untuk display cover (seperti logika lama)
    var firstItem = listItemsJson?.isNotEmpty == true ? listItemsJson![0] : null;
    var produk = firstItem != null ? firstItem['produk'] : null;

    return TransaksiModel(
      id: json['id'],
      title: produk != null ? produk['nama_produk'] : (json['order_id'] ?? 'Pesanan'),
      date: json['created_at'] ?? '-',
      price: "Rp ${json['total_harga']}", 
      status: json['order_status'] ?? 'Unknown',
      imageUrl: produk != null ? produk['image_url'] : 'https://via.placeholder.com/150',
      items: parsedItems, // <--- 4. Masukkan ke object
    );
  }

  bool get isWaiting => status == 'menunggu konfirmasi';
  bool get isProcessed => status == 'Diproses';
  bool get isShipped => status == 'Dikirim';
  bool get isSuccess => status == 'Tiba di tujuan';
  bool get isCancelled => status == 'Cancel';
}