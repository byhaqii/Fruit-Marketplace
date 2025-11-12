// lib/models/transaksi_model.dart

class TransaksiModel {
  final String title;
  final String date;
  final String weight;
  final String price;
  final String status;
  final String imageUrl;

  // Constructor
  const TransaksiModel({
    required this.title,
    required this.date,
    required this.weight,
    required this.price,
    required this.status,
    required this.imageUrl,
  });

  // Helper method untuk membuat objek dari Map (berguna untuk data dari API atau inisialisasi seperti yang Anda lakukan)
  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      title: map['title'] as String,
      date: map['date'] as String,
      weight: map['weight'] as String,
      price: map['price'] as String,
      status: map['status'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }

  // Helper method untuk konversi ke Map (berguna untuk mengirim data ke API)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'weight': weight,
      'price': price,
      'status': status,
      'imageUrl': imageUrl,
    };
  }

  // Properti turunan untuk kemudahan pengecekan status
  bool get isSuccess => status == 'Berhasil';
}