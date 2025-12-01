// lib/modules/marketplace/pages/produk_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/produk_model.dart';
import 'produk_detail_page.dart';
import 'produk_cart_page.dart';
import '../../../providers/marketplace_provider.dart';

class ProdukListPage extends StatefulWidget { // UBAH ke StatefulWidget
  static const Color kPrimaryColor = Color(0xFF1E605A);
  final String? initialSearchQuery; // NEW: Terima query pencarian

  const ProdukListPage({super.key, this.initialSearchQuery});

  @override
  State<ProdukListPage> createState() => _ProdukListPageState();
}

class _ProdukListPageState extends State<ProdukListPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan nilai query yang masuk
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    
    // TODO: Jika initialSearchQuery ada, Anda bisa memanggil fungsi filter 
    // pada MarketplaceProvider di sini untuk menyaring produk.
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  // --- WIDGET SEARCH BAR & CART (Menggunakan _searchController) ---
  Widget _buildSearchBarAndCart(BuildContext context) {
    // Menggunakan Selector untuk performa lebih baik (hanya rebuild jika cartItemCount berubah)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField( // Diubah dari const TextField
                controller: _searchController, // NEW: Gunakan controller
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (query) {
                  // TODO: Implementasi logika search/filter di sini.
                  print('Search submitted: $query');
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Ikon Keranjang
          Consumer<MarketplaceProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                    if (provider.cartItemCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                          child: Text(
                            provider.cartItemCount.toString(),
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
                    MaterialPageRoute(builder: (context) => const ProdukCartPage()),
                  );
                },
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
      backgroundColor: ProdukListPage.kPrimaryColor, // Akses static constant via class name
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: _buildSearchBarAndCart(context),
          ),
        ),
      ),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          final produkList = provider.products;

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (produkList.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada produk yang tersedia.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GridView.builder(
              itemCount: produkList.length,
              padding: EdgeInsets.only(bottom: bottomPadding + extraBottomSpace),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.67,
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
          );
        },
      ),
    );
  }
}

// --- WIDGET KARTU PRODUK (TIDAK BERUBAH) ---
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
            // Gambar Produk
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
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    );
                  },
                ),
              ),
            ),
            
            // Detail Produk
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk.namaProduk, 
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Kategori
                  Text(
                    produk.kategori.isNotEmpty ? produk.kategori : 'Umum',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Harga & Tombol Add
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Harga
                      Text(
                        produk.formattedPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      
                      // Tombol Add (Visual Saja)
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
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