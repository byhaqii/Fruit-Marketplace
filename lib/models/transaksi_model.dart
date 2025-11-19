class TransaksiModel {
  final int id;
  final String title;
  final String date;
  final String price;
  final String status;
  final String imageUrl;

  const TransaksiModel({
    required this.id,
    required this.title,
    required this.date,
    required this.price,
    required this.status,
    required this.imageUrl,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    // Ambil produk pertama dari items untuk dijadikan Judul & Gambar
    var firstItem = (json['items'] as List?)?.isNotEmpty == true 
        ? json['items'][0] 
        : null;
    var produk = firstItem != null ? firstItem['produk'] : null;

    return TransaksiModel(
      id: json['id'],
      // Jika ada produk, pakai nama produk. Jika tidak, pakai Order ID
      title: produk != null ? produk['nama_produk'] : (json['order_id'] ?? 'Pesanan'),
      // Ambil tanggal pembuatan
      date: json['created_at'] ?? '-',
      // Mapping total_harga ke price
      price: "Rp ${json['total_harga']}", 
      // Mapping order_status ke status
      status: json['order_status'] ?? 'Unknown',
      // Ambil gambar produk atau placeholder
      imageUrl: produk != null ? produk['image_url'] : 'https://via.placeholder.com/150',
    );
  }

  // Helpers untuk Status UI
  bool get isWaiting => status == 'menunggu konfirmasi';
  bool get isProcessed => status == 'Diproses';
  bool get isShipped => status == 'Dikirim';
  bool get isSuccess => status == 'Tiba di tujuan'; // Status sukses yang benar
  bool get isCancelled => status == 'Cancel';
}