// lib/models/keuangan_model.dart

class KeuanganModel {
  final int id;
  final String title;
  final String transactions; // Deskripsi singkat, misal "Transfer ke Bank"
  final String amount;       // String terformat, misal "-Rp 50.000"
  final String imageAsset;   // Ikon kategori

  const KeuanganModel({
    required this.id,
    required this.title,
    required this.transactions,
    required this.amount,
    required this.imageAsset,
  });

  // Factory untuk mengubah JSON menjadi Object
  factory KeuanganModel.fromJson(Map<String, dynamic> json) {
    return KeuanganModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Transaksi',
      transactions: json['description'] ?? '-',
      amount: json['amount_formatted'] ?? 'Rp 0',
      imageAsset: json['icon_url'] ?? 'assets/icons/default.png', 
      // Catatan: Pastikan path icon sesuai dengan asset yang Anda punya
    );
  }
}