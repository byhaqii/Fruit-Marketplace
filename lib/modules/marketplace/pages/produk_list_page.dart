// lib/modules/marketplace/page/produk_list_page.dart
import 'package:flutter/material.dart';
// Asumsi jalur ini benar:
import '../../../models/produk_model.dart';
import 'produk_detail_page.dart';
import 'produk_cart_page.dart';

// --- DATA DUMMY GLOBAL (Tetap Sesuai Permintaan) ---
const String kDummyImageUrl =
    'https://images.unsplash.com/photo-1619665671569-808848d689b0';

final List<ProdukModel> kDummyProducts = [
  const ProdukModel(
    id: 'p1',
    title: 'Keripik Singkong Pedas',
    description: 'Keripik singkong buatan rumahan, renyah dan pedas.',
    price: 12000,
    imageUrl: kDummyImageUrl,
    category: 'Makanan Ringan',
  ),
  const ProdukModel(
    id: 'p2',
    title: 'Sayur Bayam Segar',
    description: 'Bayam organik dipanen pagi hari dari kebun sendiri.',
    price: 7500,
    imageUrl: kDummyImageUrl,
    category: 'Sayuran',
  ),
  const ProdukModel(
    id: 'p3',
    title: 'Jasa Servis Komputer',
    description:
        'Menerima servis laptop dan komputer, instalasi software dan hardware.',
    price: 150000,
    imageUrl: kDummyImageUrl,
    category: 'Jasa',
  ),
];
// -------------------------

// --- HAPUS: main() dan MyApp() ---

class ProdukListPage extends StatelessWidget {
  // 1. Tambahkan konstanta warna hijau
  static const Color kPrimaryColor = Color(0xFF1E605A);

  const ProdukListPage({super.key});

  // --- WIDGET SEARCH BAR (Sesuai Gambar) ---
  Widget _buildSearchBarAndCart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              // 2. Ubah dekorasi search bar
              decoration: BoxDecoration(
                color: Colors.white, // Latar putih
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!), // Border abu-abu
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Ikon keranjang
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 12, minHeight: 12),
                    child: Text(
                      kDummyProducts.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CartScreen(cartItems: kDummyProducts)),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produkList = kDummyProducts;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const extraBottomSpace = 90.0;

    return Scaffold(
      // 3. Ubah warna latar belakang Scaffold
      backgroundColor: kPrimaryColor,

      // 4. AppBar dibuat putih
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          color: Colors.white, // Latar belakang AppBar putih
          child: SafeArea(
            child: _buildSearchBarAndCart(context),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GridView.builder(
          itemCount: produkList.length,
          padding: EdgeInsets.only(bottom: bottomPadding + extraBottomSpace),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            // 5. UBAH: Perbaiki Rasio Aspek untuk mengatasi overflow
            childAspectRatio: 0.67, // Memberi tinggi sedikit lebih banyak
          ),
          itemBuilder: (context, index) {
            final item = produkList[index];
            return ProdukCard(
              produk: item,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProdukDetailPage(produk: item)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// --- ProdukCard (Dimodifikasi) ---
class ProdukCard extends StatelessWidget {
  final ProdukModel produk;
  final VoidCallback onTap;

  const ProdukCard({required this.produk, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // 6. Pastikan Card berwarna putih
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          // 7. Samakan border dengan search bar
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Hero(
                tag: produk.id,
                child: Image.network(
                  produk.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk.title, // "Keripik Singkong Pedas"
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // 8. Teks "500 g (1pcs)"
                  const Text(
                    '500 g (1pcs)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  // -------------------------

                  const SizedBox(height: 8), // Tetap 8 agar tidak terlalu jauh
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        produk.formattedPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}