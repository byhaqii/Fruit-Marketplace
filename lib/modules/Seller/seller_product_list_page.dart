// lib/modules/Seller/seller_product_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/produk_model.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart'; // <-- Pastikan ini ada
import 'product_form_page.dart';

class SellerProductListPage extends StatefulWidget {
  const SellerProductListPage({super.key});

  @override
  State<SellerProductListPage> createState() => _SellerProductListPageState();
}

class _SellerProductListPageState extends State<SellerProductListPage> {
  // --- STATE PENCARIAN ---
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // --- KATEGORI STATUS FILTER ---
  final List<String> _statusCategories = [
    "All",
    "Active",
    "Low Stock",
    "Out of Stock",
  ];

  int _selectedStatusIndex = 0;

  Future<void> _refreshProducts() async {
    await Provider.of<MarketplaceProvider>(
      context,
      listen: false,
    ).fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2D7F6A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(25, 50, 25, 15),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LOGIKA JUDUL / SEARCH BAR
                      _isSearching
                          ? Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Search product name...",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value.toLowerCase();
                                  });
                                },
                              ),
                            )
                          : Builder(
                              builder: (context) {
                                final role = context
                                    .read<AuthProvider>()
                                    .user
                                    ?.role
                                    ?.toLowerCase();
                                final isAdmin = role == 'admin';
                                final title = isAdmin
                                    ? 'Marketplace'
                                    : 'My Products';
                                return Text(
                                  title,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: primaryColor,
                                  ),
                                );
                              },
                            ),

                      // TOMBOL AKSI (SEARCH & ADD)
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_isSearching) {
                                  _isSearching = false;
                                  _searchQuery = "";
                                  _searchController.clear();
                                } else {
                                  _isSearching = true;
                                }
                              });
                            },
                            icon: Icon(
                              _isSearching ? Icons.close : Icons.search,
                              color: primaryColor,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 5),

                          if (!_isSearching) ...[
                            InkWell(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProductFormPage(),
                                  ),
                                );
                                if (result == true) {
                                  // Refresh list to show newly added product
                                  await _refreshProducts();
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Product saved'),
                                    ),
                                  );
                                  setState(() {});
                                }
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: primaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // TAB FILTER (Horizontal Scroll)
                if (!_isSearching)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: List.generate(_statusCategories.length, (
                        index,
                      ) {
                        final isSelected = _selectedStatusIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedStatusIndex = index),
                            child: Column(
                              children: [
                                Text(
                                  _statusCategories[index],
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 14,
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.grey[400],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),

          // 2. DAFTAR PRODUK (CONTENT)
          // Menggunakan Consumer2 untuk mendapatkan data produk dan data pengguna
          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              onRefresh: _refreshProducts,
              child: Consumer2<MarketplaceProvider, AuthProvider>(
                builder: (context, provider, authProvider, child) {
                  // Konversi ID pengguna (String) ke int dengan aman
                  final int? currentUserId = int.tryParse(
                    authProvider.user?.id ?? '',
                  );

                  if (provider.isLoading || currentUserId == null) {
                    return ColoredBox(
                      color: const Color(0xFF2D7F6A),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 240),
                          Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Start with all products then filter by ownership
                  List<ProdukModel> products = provider.products;
                  final List<ProdukModel> ownedAll = products
                      .where((p) => p.userId == currentUserId)
                      .toList();
                  // Work on owned products for further filters/display
                  products = List<ProdukModel>.from(ownedAll);

                  // --- LOGIKA FILTER 1: PENCARIAN ---
                  if (_searchQuery.isNotEmpty) {
                    products = products
                        .where(
                          (p) =>
                              p.namaProduk.toLowerCase().contains(_searchQuery),
                        )
                        .toList();
                  }

                  // --- FILTER 2: STATUS/CATEGORY ---
                  if (_selectedStatusIndex != 0 && _searchQuery.isEmpty) {
                    final filter = _statusCategories[_selectedStatusIndex];

                    products = products.where((p) {
                      final status = p.statusJual.toLowerCase();

                      if (filter == "Active") {
                        // Consider available/active statuses as active
                        return status == 'tersedia' ||
                            status == 'aktif' ||
                            status == 'available' ||
                            status == 'active';
                      } else if (filter == "Low Stock") {
                        return p.stok <= 5 && p.stok > 0;
                      } else if (filter == "Out of Stock") {
                        return p.stok == 0 ||
                            status == 'tidak tersedia' ||
                            status == 'nonaktif' ||
                            status == 'unavailable' ||
                            status == 'inactive';
                      }
                      return true;
                    }).toList();
                  }

                  // EMPTY STATE
                  if (products.isEmpty) {
                    return LayoutBuilder(
                      builder: (ctx, constraints) {
                        return ColoredBox(
                          color: const Color(0xFF2D7F6A),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: _buildEmptyState(
                                context,
                                primaryColor,
                                isSearch: _searchQuery.isNotEmpty,
                                hasAnyProduct: ownedAll.isNotEmpty,
                                filterCategory: _selectedStatusIndex != 0
                                    ? _statusCategories[_selectedStatusIndex]
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // RENDER LIST
                  return Container(
                    color: const Color(0xFF2D7F6A),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(
                          context,
                          products[index],
                          provider,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET KARTU PRODUK ---
  Widget _buildProductCard(
    BuildContext context,
    ProdukModel item,
    MarketplaceProvider provider,
  ) {
    bool isLowStock = item.stok <= 5 && item.stok > 0;
    bool isEmpty = item.stok == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FOTO PRODUK
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                item.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[100],
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // INFO PRODUK
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaProduk,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.formattedPrice,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF2D7F6A),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    // CHIP STOK DENGAN WARNA DINAMIS
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isEmpty
                            ? Colors.red.withOpacity(0.1)
                            : (isLowStock
                                  ? Colors.orange.withOpacity(0.1)
                                  : const Color(0xFFF5F7FA)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 12,
                            color: isEmpty
                                ? Colors.red
                                : (isLowStock ? Colors.orange : Colors.grey),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isEmpty ? "Out of stock" : "${item.stok} Stock",
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              color: isEmpty
                                  ? Colors.red
                                  : (isLowStock ? Colors.orange : Colors.grey),
                              fontWeight: isLowStock || isEmpty
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // CHIP KATEGORI
                    if (item.kategori.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.kategori,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00695C),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // AKSI
          Column(
            children: [
              InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductFormPage(produk: item),
                    ),
                  );
                  if (result == true) {
                    await _refreshProducts();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product saved')),
                    );
                    setState(() {});
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 22,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _confirmDelete(context, provider, item.id),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.delete_outline,
                    size: 22,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color primaryColor, {
    bool isSearch = false,
    bool hasAnyProduct = false,
    String? filterCategory,
  }) {
    String emptyMessage;
    if (isSearch) {
      emptyMessage = "Product not found";
    } else if (filterCategory != null) {
      emptyMessage = "No $filterCategory products";
    } else {
      emptyMessage = "No products yet";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch ? Icons.search_off : Icons.shopping_bag_outlined,
            size: 70,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Text(
            emptyMessage,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          // Show "Add Now" only if user truly has no products at all
          if (!isSearch && !hasAnyProduct)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductFormPage()),
                ),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "Add Now",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    MarketplaceProvider provider,
    int id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Hapus Produk?",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: const Text("Produk yang dihapus tidak dapat dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteProduct(id);
              if (mounted)
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Produk dihapus")));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
