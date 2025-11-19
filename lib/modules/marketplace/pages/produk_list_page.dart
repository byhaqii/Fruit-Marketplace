// lib/modules/marketplace/page/produk_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. TAMBAHKAN IMPORT
import '../../../models/produk_model.dart';
import 'produk_detail_page.dart';
import 'produk_cart_page.dart';
import '../../../providers/marketplace_provider.dart'; // <-- 2. TAMBAHKAN IMPORT

// --- DATA DUMMY GLOBAL (kDummyImageUrl dan kDummyProducts) DIHAPUS ---

class ProdukListPage extends StatelessWidget {
  // 1. Tambahkan konstanta warna hijau
  static const Color kPrimaryColor = Color(0xFF1E605A);

  const ProdukListPage({super.key});

  // --- WIDGET SEARCH BAR (Sesuai Gambar) ---
  Widget _buildSearchBarAndCart(BuildContext context) {
    // 3. Ambil cartItemCount dari provider
    final cartItemCount = Provider.of<MarketplaceProvider>(context).cartItemCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
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
                // 4. Tampilkan badge hanya jika ada item
                if (cartItemCount > 0)
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
                        cartItemCount.toString(), // <-- Gunakan data provider
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
                    // 5. HAPUS 'cartItems' dari constructor
                    builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const extraBottomSpace = 90.0;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          color: Colors.white, // Latar belakang AppBar putih
          child: SafeArea(
            child: _buildSearchBarAndCart(context),
          ),
        ),
      ),
      // 6. GANTI BODY DENGAN CONSUMER
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          // Asumsi: MarketplaceProvider punya list 'products'
          final produkList = provider.products;

          // Tampilkan loading
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }

          // Tampilkan pesan jika kosong
          if (produkList.isEmpty) {
            return const Center(
                child: Text(
              'Tidak ada produk yang tersedia.',
              style: TextStyle(color: Colors.white70),
            ));
          }

          // Tampilkan GridView jika ada data
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GridView.builder(
              itemCount: produkList.length, // <-- Gunakan data provider
              padding: EdgeInsets.only(bottom: bottomPadding + extraBottomSpace),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.67,
              ),
              itemBuilder: (context, index) {
                final item = produkList[index]; // <-- Gunakan data provider
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
          );
        },
      ),
    );
  }
}

// --- ProdukCard (Tidak Berubah) ---
class ProdukCard extends StatelessWidget {
  final ProdukModel produk;
  final VoidCallback onTap;

  const ProdukCard({required this.produk, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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
                    produk.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '500 g',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
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