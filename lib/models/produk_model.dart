// lib/models/produk_model.dart

class ProdukModel {
  final String id;
  final String title;
  final String description;
  final int price; // Harga dalam rupiah (contoh: 50000)
  final String imageUrl;
  final String category; // Kategori produk

  const ProdukModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  /// Mengembalikan harga dalam format "Rp. 50.000"
  String get formattedPrice {
    final s = price.toString();
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

    // Mengembalikan string yang terbalik kembali ke urutan yang benar
    return 'Rp. ${buffer.toString().split('').reversed.join()}';
  }

  /// Factory method opsional: mempermudah parsing dari Map (misal dari JSON)
  factory ProdukModel.fromMap(Map<String, dynamic> map) {
    return ProdukModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
    );
  }

  /// Mengubah kembali ke Map (berguna untuk simpan ke database / API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}