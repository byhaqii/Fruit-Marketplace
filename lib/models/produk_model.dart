// lib/models/produk_model.dart
class ProdukModel {
  final String id;
  final String title;
  final String description;
  final int price; // price in whole rupiah (e.g. 50000)
  final String imageUrl;

  ProdukModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

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
    return 'Rp. ${buffer.toString().split('').reversed.join()}';
  }
}
