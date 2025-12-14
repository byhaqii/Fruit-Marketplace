// lib/modules/marketplace/pages/produk_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/produk_model.dart';
import 'produk_detail_page.dart';
import 'produk_cart_page.dart';
import '../../../providers/marketplace_provider.dart';

// --- PRODUK LIST PAGE ---

class ProdukListPage extends StatefulWidget {
  static const Color kPrimaryColor = Color(
    0xFF2D7F6A,
  ); // Warna Latar Belakang Tetap
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
      // Fetch products otomatis saat halaman dibuka
      _fetchAndFilterProducts();
    });
  }

  void _onSearchChanged() {
    Provider.of<MarketplaceProvider>(
      context,
      listen: false,
    ).filterProducts(_searchController.text);
  }

  Future<void> _fetchAndFilterProducts() async {
    final provider = Provider.of<MarketplaceProvider>(context, listen: false);
    await provider.fetchProducts();
    // Apply filter based on initial search query or keep current search
    final query = _searchController.text;
    provider.filterProducts(query);
  }

  Future<void> _refreshProducts() async {
    final provider = Provider.of<MarketplaceProvider>(context, listen: false);
    await provider.fetchProducts();
    // Reset search and show all products when pull-to-refresh
    _searchController.clear();
    provider.filterProducts('');
  }

  // Prompt for quantity before adding to cart
  Future<void> _promptAddToCart(
    BuildContext context,
    ProdukModel produk,
    MarketplaceProvider provider,
  ) async {
    int qty = 1;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        const Color primaryColor = Color(0xFF2D7F6A);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Add to Cart'),
          content: StatefulBuilder(
            builder: (ctx, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          produk.imageUrl,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 54,
                            height: 54,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produk.namaProduk,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Available: ${produk.stok}',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (qty > 1) qty -= 1;
                                });
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                              color: primaryColor,
                            ),
                            Container(
                              width: 42,
                              alignment: Alignment.center,
                              child: Text(
                                '$qty',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (qty < (produk.stok)) qty += 1;
                                });
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(qty),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    qty = (result ?? 0);
    if (qty > 0) {
      for (int i = 0; i < qty; i++) {
        provider.incrementQuantity(produk);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $qty x ${produk.namaProduk}')),
      );
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              // Tetap menggunakan Row agar SEJAJAR VERTIKAL (Center)
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ikon Search
                  const Icon(Icons.search, color: Colors.grey),

                  const SizedBox(width: 8),

                  // TextField
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      // Tidak ada properti 'style' di sini (mengikuti default)
                      decoration: const InputDecoration(
                        hintText: 'Search Products...',
                        // HAPUS hintStyle agar warna & tebalnya persis kode referensi (default)
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // --- Ikon Keranjang (Tidak Berubah) ---
          Consumer<MarketplaceProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black,
                      size: 28,
                    ),
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
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            provider.cartItemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
                      builder: (context) => const ProdukCartPage(),
                    ),
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
    const safeBottomClearance = 8.0;

    return Scaffold(
      backgroundColor: ProdukListPage.kPrimaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          color: Colors.white,
          child: SafeArea(child: _buildSearchBarAndCart(context)),
        ),
      ),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          final produkList = provider.products;
          final currentQuery = _searchController.text;

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (produkList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshProducts,
              color: ProdukListPage.kPrimaryColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 16.0,
                        bottom: 8.0,
                      ),
                      child: Text(
                        currentQuery.isNotEmpty
                            ? 'Search Results for "${currentQuery}"'
                            : 'Marketplace',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentQuery.isNotEmpty ? 'Not Found' : 'No Products',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentQuery.isNotEmpty
                          ? 'Product "${currentQuery}" not available'
                          : 'No products available yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshProducts,
            color: ProdukListPage.kPrimaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header List Produk
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      bottom: 8.0,
                    ),
                    child: Text(
                      currentQuery.isNotEmpty
                          ? 'Search Results for "$currentQuery"'
                          : 'All Products',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.60,
                          ),
                      itemBuilder: (context, index) {
                        final item = produkList[index];
                        return ProdukCard(
                          produk: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProdukDetailPage(produk: item),
                              ),
                            );
                          },
                          onAddToCart: (p) {
                            _promptAddToCart(context, p, provider);
                          },
                        );
                      },
                    ),
                  ),

                  // PADDING AKHIR yang sangat kecil untuk mencegah overflow
                  const SizedBox(height: safeBottomClearance),
                ],
              ),
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
    super.key,
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
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Detail Produk
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produk.namaProduk,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Kategori
                    Text(
                      produk.kategori.isNotEmpty ? produk.kategori : 'Umum',
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // const Spacer(),
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
                                BoxShadow(
                                  color: kPrimaryColor.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 20,
                            ),
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
