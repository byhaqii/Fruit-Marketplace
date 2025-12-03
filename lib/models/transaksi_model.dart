// lib/models/transaksi_model.dart

import 'produk_model.dart';

class TransaksiModel {
  final int id;
  final String orderId;   // <--- 1. Tambahan: Untuk ditampilkan di dashboard
  final int totalHarga;   // <--- 2. Tambahan: Untuk kalkulasi saldo di provider
  final String title;
  final String date;
  final String price;     // String terformat "Rp ..."
  final String status;
  final String imageUrl;
  final List<ProdukModel> items;

  const TransaksiModel({
    required this.id,
    required this.orderId,    // <--- Wajib diisi
    required this.totalHarga, // <--- Wajib diisi
    required this.title,
    required this.date,
    required this.price,
    required this.status,
    required this.imageUrl,
    required this.items,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    // Dukungan agar bisa membaca key 'items' atau 'order_items' dari backend
    var listItemsJson = (json['items'] ?? json['order_items']) as List?;
    
    List<ProdukModel> parsedItems = [];
    if (listItemsJson != null) {
      parsedItems = listItemsJson.map((itemJson) {
        return ProdukModel.fromJson(itemJson['produk'] ?? {});
      }).toList();
    }

    var firstItem = listItemsJson?.isNotEmpty == true ? listItemsJson![0] : null;
    var produk = firstItem != null ? firstItem['produk'] : null;

    // Hitung jumlah item untuk judul ringkasan
    final int itemCount = listItemsJson?.length ?? 0;

    // LOGIKA PERBAIKAN UNTUK TITLE:
    String calculatedTitle = 'Pesanan #${json['order_id'] ?? '-'}'; 
    if (itemCount == 1 && produk != null) {
      // Jika hanya 1 barang, tampilkan nama barangnya
      calculatedTitle = produk['nama_produk'] ?? 'Produk';
    } else if (itemCount > 1) {
      // Jika lebih dari 1, tampilkan nama barang pertama + jumlah produk lainnya
      String firstName = produk != null ? (produk['nama_produk'] ?? 'Produk') : 'Produk';
      calculatedTitle = "$firstName dan ${itemCount - 1} Produk Lainnya";
    }

    // Parsing aman untuk total harga
    int rawHarga = 0;
    if (json['total_harga'] != null) {
      rawHarga = int.tryParse(json['total_harga'].toString()) ?? 0;
    }

    return TransaksiModel(
      id: json['id'],
      orderId: json['order_id'] ?? '-', // Ambil Order ID
      totalHarga: rawHarga,            // Simpan nilai integer
      title: calculatedTitle, // <-- Menggunakan title yang sudah diperbarui
      date: json['created_at'] ?? '-',
      price: "Rp ${json['total_harga']}", 
      status: json['order_status'] ?? 'Unknown',
      // Cek variasi nama field image dari backend (image vs image_url)
      imageUrl: produk != null 
          ? (produk['image'] ?? produk['image_url'] ?? 'https://via.placeholder.com/150') 
          : 'https://via.placeholder.com/150',
      items: parsedItems,
    );
  }

  // Helper getters
  bool get isWaiting => status == 'menunggu konfirmasi';
  bool get isProcessed => status == 'Diproses';
  bool get isShipped => status == 'Dikirim';
  
  // PERBAIKAN 1: Tambahkan getter untuk status yang memungkinkan penerimaan barang.
  bool get isReceivable => status == 'Dikirim' || status == 'Tiba di tujuan';

  // PERBAIKAN 2: isSuccess hanya untuk status yang sudah selesai/siap diulas.
  bool get isSuccess => status == 'Selesai';

  // PERBAIKAN 3: isCancelled hanya menggunakan status dari enum backend
  bool get isCancelled => status == 'Dibatalkan'; 
}