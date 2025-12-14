// lib/modules/marketplace/pages/produk_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/produk_model.dart';
import '../../../providers/marketplace_provider.dart';
import 'produk_cart_page.dart'; // Untuk navigasi ke keranjang

class ProdukDetailPage extends StatefulWidget {
  final ProdukModel produk;

  const ProdukDetailPage({super.key, required this.produk});

  @override
  State<ProdukDetailPage> createState() => _ProdukDetailPageState();
}

class _ProdukDetailPageState extends State<ProdukDetailPage> {
  // Warna hijau utama (sesuai tema aplikasi)
  static const Color kPrimaryColor = Color(0xFF1E605A);

  @override
  Widget build(BuildContext context) {
    // Pastikan stok dikonversi ke string dengan aman
    final String stokText = widget.produk.stok.toString();

    return Scaffold(
      backgroundColor: Colors.white,
      // Menggunakan Stack agar gambar bisa full screen di belakang AppBar transparan
      body: Stack(
        children: [
          // 1. GAMBAR PRODUK & KONTEN SCROLLABLE
          CustomScrollView(
            slivers: [
              // --- AppBar & Gambar ---
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: kPrimaryColor,
                leading: IconButton(
                  icon: const ContainerIcon(icon: Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  // Tombol Keranjang di Pojok Kanan Atas
                  Consumer<MarketplaceProvider>(
                    builder: (context, provider, child) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: IconButton(
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const ContainerIcon(icon: Icons.shopping_cart_outlined),
                              if (provider.cartItemCount > 0)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${provider.cartItemCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProdukCartPage()),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: widget.produk.id,
                    child: Image.network(
                      widget.produk.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 50, color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
              ),

              // --- Detail Produk ---
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  // Transform sedikit ke atas agar menutupi bagian bawah gambar
                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Garis indikator kecil (pemanis UI)
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Kategori & Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.produk.kategori.isNotEmpty
                                    ? widget.produk.kategori
                                    : 'Umum',
                                style: const TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              widget.produk.stok > 0 ? 'Tersedia' : 'Stok Habis',
                              style: TextStyle(
                                color: widget.produk.stok > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Nama Produk
                        Text(
                          widget.produk.namaProduk,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Harga
                        Text(
                          widget.produk.formattedPrice,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Deskripsi Judul
                        const Text(
                          "Deskripsi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Isi Deskripsi
                        Text(
                          widget.produk.deskripsi.isNotEmpty
                              ? widget.produk.deskripsi
                              : "Tidak ada deskripsi untuk produk ini.",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        
                        // Info Tambahan (Stok) - PERBAIKAN DI SINI
                        const SizedBox(height: 16),
                        Row(
                          children: [
                             const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey),
                             const SizedBox(width: 8),
                             Text('Sisa Stok: $stokText', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        
                        // Spacer agar tidak tertutup tombol bawah
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. TOMBOL AKSI DI BAGIAN BAWAH (Floating)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Tombol Chat / Favorit (Opsional)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.grey),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Fitur Wishlist belum tersedia")),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Tombol Tambah ke Keranjang
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: widget.produk.stok > 0 
                          ? () {
                              // Panggil Provider untuk tambah item
                              Provider.of<MarketplaceProvider>(context, listen: false)
                                  .incrementQuantity(widget.produk);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${widget.produk.namaProduk} ditambahkan ke keranjang"),
                                  backgroundColor: kPrimaryColor,
                                  duration: const Duration(milliseconds: 1500),
                                  action: SnackBarAction(
                                    label: 'LIHAT',
                                    textColor: Colors.white,
                                    onPressed: () {
                                       Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const ProdukCartPage()),
                                        );
                                    },
                                  ),
                                ),
                              );
                            }
                          : null, // Disable jika stok habis
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.produk.stok > 0 ? 'Add to Cart' : 'Out of Stock',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget untuk icon bulat kecil di AppBar
class ContainerIcon extends StatelessWidget {
  final IconData icon;
  const ContainerIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3), // Digelapkan agar terlihat di atas gambar terang
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}