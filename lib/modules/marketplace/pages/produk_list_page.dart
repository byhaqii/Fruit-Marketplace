// lib/modules/marketplace/pages/produk_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/produk_model.dart';
import 'produk_detail_page.dart';
import 'produk_cart_page.dart';
import '../../../providers/marketplace_provider.dart';

// --- PRODUK LIST PAGE ---

class ProdukListPage extends StatefulWidget { 
  static const Color kPrimaryColor = Color(0xFF1E605A);
  final String? initialSearchQuery; 

  const ProdukListPage({super.key, this.initialSearchQuery});

  @override
  State<ProdukListPage> createState() => _ProdukListPageState();
}

class _ProdukListPageState extends State<ProdukListPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    _searchController.addListener(_onSearchChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onSearchChanged();
    });
  }

  void _onSearchChanged() {
    Provider.of<MarketplaceProvider>(context, listen: false)
            .filterProducts(_searchController.text);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }


  // --- WIDGET SEARCH BAR & CART ---
  Widget _buildSearchBarAndCart(BuildContext context) {
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
              child: TextField( 
                controller: _searchController, 
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
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
    // Padding aman 200.0 piksel untuk membersihkan BottomBar
    const safeBottomClearance = 200.0; 

    return Scaffold(
      backgroundColor: ProdukListPage.kPrimaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: _buildSearchBarAndCart(context),
          ),
        ),
      ),
      // STRUKTUR STABIL: SingleChildScrollView + GridView non-scrollable
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          final produkList = provider.products;
          final currentQuery = _searchController.text;

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (produkList.isEmpty) {
            return Center(
              child: Text(
                currentQuery.isNotEmpty 
                  ? 'Produk dengan nama "$currentQuery" tidak ditemukan.'
                  : 'Tidak ada produk yang tersedia.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          return SingleChildScrollView( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header List Produk
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                  child: Text(
                    currentQuery.isNotEmpty ? 'Hasil Pencarian untuk "$currentQuery"' : 'Semua Produk',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                
                // GridView
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    shrinkWrap: true, // Wajib: GridView akan mengambil tinggi sesuai konten
                    physics: const NeverScrollableScrollPhysics(), // Wajib: Scroll ditangani oleh SingleChildScrollView
                    itemCount: produkList.length,
                    padding: EdgeInsets.zero, // Hapus padding default
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
                        onAddToCart: (p) {
                          provider.incrementQuantity(p);
                        },
                      );
                    },
                  ),
                ),
                
                // PADDING AKHIR: Memberikan ruang aman 200.0 piksel untuk clearance
                const SizedBox(height: safeBottomClearance), 

              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGET KARTU PRODUK (tetap sama) ---
class ProdukCard extends StatelessWidget {
  final ProdukModel produk;
  final VoidCallback onTap;
  final void Function(ProdukModel) onAddToCart; 

  const ProdukCard({
    required this.produk, 
    required this.onTap, 
    required this.onAddToCart, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 2, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
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
                        fontWeight: FontWeight.w700, fontSize: 16),
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
                          fontSize: 16, 
                          color: Colors.black,
                        ),
                      ),
                      
                      // Tombol Add (Dibuat Fungsional)
                      GestureDetector(
                        onTap: () => onAddToCart(produk), // Panggil callback saat di-tap
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
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