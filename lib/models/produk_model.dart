// lib/models/produk_model.dart

class ProdukModel {
  // Kita gunakan tipe data yang sesuai dengan database Laravel
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

  // Getter untuk kompatibilitas dengan kode UI lama (agar tidak perlu ubah semua UI)
  String get title => namaProduk;
  int get price => harga;

  // Helper format Rupiah
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
    return 'Rp. ${buffer.toString().split('').reversed.join()}';
  }

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    // --- FUNGSI PENYELAMAT (ANTI-ERROR) ---
    // Fungsi ini memaksa data apapun menjadi Integer yang aman
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    // Fungsi ini memaksa data apapun menjadi String yang aman
    String parseString(dynamic val, {String defaultValue = '-'}) {
      if (val == null) return defaultValue;
      return val.toString();
    }

    return ProdukModel(
      // Gunakan helper di sini untuk mencegah crash 'int is not subtype of String'
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      
      // Mapping nama field dari database (snake_case) ke model (camelCase)
      namaProduk: parseString(json['nama_produk'], defaultValue: 'Tanpa Nama'),
      deskripsi: parseString(json['deskripsi'], defaultValue: '-'),
      
      harga: parseInt(json['harga']),
      stok: parseInt(json['stok']),
      
      imageUrl: (json['gambar_url'] != null && json['gambar_url'].toString().isNotEmpty)
          ? json['gambar_url'].toString()
          : 'https://via.placeholder.com/150',
          
      kategori: parseString(json['kategori'], defaultValue: 'Umum'),
      statusJual: parseString(json['status_jual'], defaultValue: 'Tersedia'),
    );
  }

  // Helper untuk kompatibilitas jika ada kode lama yang memanggil fromMap
  factory ProdukModel.fromMap(Map<String, dynamic> map) => ProdukModel.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
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
}