// lib/modules/marketplace/pages/produk_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/produk_model.dart';
import 'produk_detail_page.dart';
import 'produk_cart_page.dart';
import '../../../providers/marketplace_provider.dart';

// --- PRODUK LIST PAGE ---

class ProdukListPage extends StatefulWidget { 
  static const Color kPrimaryColor = Color(0xFF1E605A); // Warna Latar Belakang Tetap
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
                boxShadow: [ 
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                ]
              ),
              child: TextField( 
                controller: _searchController, 
                decoration: const InputDecoration(
                  hintText: 'Cari Produk...', 
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
                    // Ikon Keranjang Utama
                    const Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 28), 
                    if (provider.cartItemCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4), 
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            provider.cartItemCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
    // PERBAIKAN UTAMA: Mengurangi padding aman ke nilai yang sangat kecil
    // Nilai 8.0 piksel seharusnya cukup untuk menghilangkan sisa overflow 17px.
    const safeBottomClearance = 8.0; 

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
                      fontSize: 20, 
                      fontWeight: FontWeight.w900
                    ),
                  ),
                ),
                
                // GridView
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(), 
                    itemCount: produkList.length,
                    padding: EdgeInsets.zero, 
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
                
                // PADDING AKHIR yang sangat kecil untuk mencegah overflow
                const SizedBox(height: safeBottomClearance), 

              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGET KARTU PRODUK (Tampilan Diperbaiki) ---
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
    const Color kPrimaryColor = ProdukListPage.kPrimaryColor;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), 
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
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
            Expanded( 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produk.namaProduk, 
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87), 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Kategori
                    Text(
                      produk.kategori.isNotEmpty ? produk.kategori : 'Umum',
                      style: const TextStyle(color: kPrimaryColor, fontSize: 12, fontWeight: FontWeight.w500), 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    const Spacer(), 
                    // Harga & Tombol Add
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Harga
                        Expanded(
                          child: Text(
                            produk.formattedPrice,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: 17, 
                              color: kPrimaryColor, 
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Tombol Add 
                        GestureDetector(
                          onTap: () => onAddToCart(produk), 
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(color: kPrimaryColor.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2))
                              ]
                            ),
                            child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}