// lib/models/transaksi_model.dart

import 'produk_model.dart';

class TransaksiModel {
  final int id;
  final String orderId;   
  final int totalHarga;   
  final String title;
  final String date;
  final String price;     
  final String status;
  final String imageUrl;
  final List<ProdukModel> items;

  const TransaksiModel({
    required this.id,
    required this.orderId,    
    required this.totalHarga, 
    required this.title,
    required this.date,
    required this.price,
    required this.status,
    required this.imageUrl,
    required this.items,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    
    var listItemsJson = (json['items'] ?? json['order_items']) as List?;
    
    List<ProdukModel> parsedItems = [];
    if (listItemsJson != null) {
      parsedItems = listItemsJson.map((itemJson) {
        
        return ProdukModel.fromJson(itemJson['produk'] ?? {});
      }).toList();
    }

    var firstItem = listItemsJson?.isNotEmpty == true ? listItemsJson![0] : null;
    var produk = firstItem != null ? firstItem['produk'] : null;

    
    final int itemCount = listItemsJson?.length ?? 0;

    
    String calculatedTitle = 'Pesanan #${json['order_id'] ?? '-'}'; 
    if (itemCount == 1 && produk != null) {
      
      calculatedTitle = produk['nama_produk'] ?? 'Produk';
    } else if (itemCount > 1) {
      
      String firstName = produk != null ? (produk['nama_produk'] ?? 'Produk') : 'Produk';
      calculatedTitle = "$firstName dan ${itemCount - 1} Produk Lainnya";
    }

    
    int rawHarga = 0;
    if (json['total_harga'] != null) {
      rawHarga = int.tryParse(json['total_harga'].toString()) ?? 0;
    }

    
    String? rawImageName;
    if (produk != null) {
      
      rawImageName = produk['gambar_url'] ?? produk['image_url'] ?? produk['image'];
    }

    String finalImageUrl = 'https://via.placeholder.com/150';
    if (rawImageName != null && rawImageName.isNotEmpty) {
      
      
      finalImageUrl = '/storage/$rawImageName'; 
    }
    

    return TransaksiModel(
      id: json['id'],
      orderId: json['order_id'] ?? '-',
      totalHarga: rawHarga,
      title: calculatedTitle,
      date: json['created_at'] ?? '-',
      price: "Rp ${json['total_harga']}", 
      status: json['order_status'] ?? 'Unknown',
      imageUrl: finalImageUrl,
      items: parsedItems,
    );
  }

  
  bool get isWaiting => status == 'menunggu konfirmasi';
  bool get isProcessed => status == 'Diproses';
  bool get isShipped => status == 'Dikirim';
  
  
  bool get isReceivable => status == 'Dikirim' || status == 'Tiba di tujuan';

  
  bool get isSuccess => status == 'Selesai';

  
  bool get isCancelled => status == 'Dibatalkan'; 
}