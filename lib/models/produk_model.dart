// lib/models/produk_model.dart
import '../config/env.dart'; // <--- 1. JANGAN LUPA IMPORT INI UNTUK BASE URL

class ProdukModel {
  final int id;
  final int userId;
  final String namaProduk;
  final String deskripsi;
  final int harga;
  final int stok;
  final String imageUrl;
  final String kategori;
  final String statusJual;

  const ProdukModel({
    required this.id,
    required this.userId,
    required this.namaProduk,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    required this.imageUrl,
    required this.kategori,
    required this.statusJual,
  });

  // Getter kompatibilitas
  String get title => namaProduk;
  int get price => harga;

  String get formattedPrice {
    final s = harga.toString();
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

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    // --- HELPERS ---
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    String parseString(dynamic val, {String defaultValue = '-'}) {
      if (val == null) return defaultValue;
      return val.toString();
    }

    // --- LOGIKA GAMBAR PINTAR ---
    String getValidImageUrl(dynamic val) {
      if (val == null || val.toString().isEmpty) {
        // Gambar default jika null
        return 'https://via.placeholder.com/150'; 
      }
      String imgString = val.toString();
      
      // Jika sudah ada 'http', berarti itu link lengkap (misal dari internet)
      if (imgString.startsWith('http')) {
        return imgString;
      } 
    
      return '${Env.apiBaseUrl}/storage/$imgString'; 
    }

    return ProdukModel(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      namaProduk: parseString(json['nama_produk'], defaultValue: 'Tanpa Nama'),
      deskripsi: parseString(json['deskripsi'], defaultValue: '-'),
      harga: parseInt(json['harga']),
      stok: parseInt(json['stok']),
      
      // Panggil fungsi gambar pintar di sini
      imageUrl: getValidImageUrl(json['gambar_url']),
      
      kategori: parseString(json['kategori'], defaultValue: 'Umum'),
      statusJual: parseString(json['status_jual'], defaultValue: 'Tersedia'),
    );
  }

  factory ProdukModel.fromMap(Map<String, dynamic> map) => ProdukModel.fromJson(map);

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'nama_produk': namaProduk,
    'deskripsi': deskripsi,
    'harga': harga,
    'stok': stok,
    'gambar_url': imageUrl,
    'kategori': kategori,
    'status_jual': statusJual,
  };
}