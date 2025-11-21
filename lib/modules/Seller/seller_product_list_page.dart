// lib/modules/Seller/seller_product_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/produk_model.dart';
import '../../providers/marketplace_provider.dart';
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
  // Menambahkan "Semua" di awal agar defaultnya tampil semua
  final List<String> _statusCategories = [
    "Semua", 
    "Aktif", 
    "Stok Rendah", 
    "Tidak Tersedia", // Mengganti 'Nonaktif' agar sesuai logic umum
  ];
  
  int _selectedStatusIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2D7F6A);

    return Scaffold(
      backgroundColor: primaryColor, 
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // LOGIKA JUDUL / SEARCH BAR
                        Expanded(
                          child: _isSearching
                              ? TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                                  decoration: const InputDecoration(
                                    hintText: "Cari nama produk...",
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value.toLowerCase();
                                    });
                                  },
                                )
                              : const Text(
                                  "Produk Saya",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: primaryColor,
                                  ),
                                ),
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
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormPage())),
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: primaryColor, width: 2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, color: primaryColor, size: 20),
                                ),
                              ),
                            ],
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // TAB FILTER (Horizontal Scroll)
                  // Disembunyikan saat mode searching agar UI bersih
                  if (!_isSearching)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: List.generate(_statusCategories.length, (index) {
                          final isSelected = _selectedStatusIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedStatusIndex = index),
                              child: Column(
                                children: [
                                  Text(
                                    _statusCategories[index],
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 14,
                                      color: isSelected ? primaryColor : Colors.grey[400],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 4, height: 4,
                                      decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                    )
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
            Expanded(
              child: Consumer<MarketplaceProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white));

                  List<ProdukModel> products = provider.products;

                  // --- LOGIKA FILTER 1: PENCARIAN ---
                  if (_searchQuery.isNotEmpty) {
                    products = products.where((p) => p.namaProduk.toLowerCase().contains(_searchQuery)).toList();
                  }

                  // --- LOGIKA FILTER 2: STATUS/KATEGORI ---
                  // Hanya jalankan jika tidak sedang mencari, atau bisa digabung
                  if (_selectedStatusIndex != 0 && _searchQuery.isEmpty) {
                    final filter = _statusCategories[_selectedStatusIndex];
                    
                    products = products.where((p) {
                      // Normalisasi string untuk perbandingan
                      final status = p.statusJual.toLowerCase(); // misal: 'tersedia', 'tidak tersedia'
                      
                      if (filter == "Aktif") {
                        // Tampilkan jika Status Tersedia
                        return status == 'tersedia' || status == 'aktif';
                      } else if (filter == "Stok Rendah") {
                        // Tampilkan jika Stok <= 5 (Batas stok rendah)
                        return p.stok <= 5 && p.stok > 0;
                      } else if (filter == "Tidak Tersedia") {
                         // Tampilkan jika status Nonaktif atau stok 0
                        return status == 'tidak tersedia' || status == 'nonaktif' || p.stok == 0;
                      }
                      // Jika ada tab lain, tampilkan semua atau sesuaikan
                      return true;
                    }).toList();
                  }

                  // EMPTY STATE
                  if (products.isEmpty) {
                    return _buildEmptyState(context, primaryColor, isSearch: _searchQuery.isNotEmpty);
                  }

                  // RENDER LIST
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(context, products[index], provider);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KARTU PRODUK ---
  Widget _buildProductCard(BuildContext context, ProdukModel item, MarketplaceProvider provider) {
    bool isLowStock = item.stok <= 5 && item.stok > 0;
    bool isEmpty = item.stok == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                item.imageUrl,
                width: 90, height: 90, fit: BoxFit.cover,
                errorBuilder: (_,__,___) => Container(
                  width: 90, height: 90, color: Colors.grey[100],
                  child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isEmpty ? Colors.red.withOpacity(0.1) : (isLowStock ? Colors.orange.withOpacity(0.1) : const Color(0xFFF5F7FA)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined, 
                            size: 12, 
                            color: isEmpty ? Colors.red : (isLowStock ? Colors.orange : Colors.grey)
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isEmpty ? "Habis" : "${item.stok} Stok", 
                            style: TextStyle(
                              fontSize: 11, 
                              fontFamily: 'Poppins', 
                              color: isEmpty ? Colors.red : (isLowStock ? Colors.orange : Colors.grey),
                              fontWeight: isLowStock || isEmpty ? FontWeight.bold : FontWeight.normal
                            )
                          ),
                        ],
                      ),
                    ),
                    // CHIP KATEGORI
                    if (item.kategori.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          item.kategori, 
                          style: const TextStyle(fontSize: 10, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Color(0xFF00695C))
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),

          // AKSI
          Column(
            children: [
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormPage(produk: item))),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.edit_outlined, size: 22, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _confirmDelete(context, provider, item.id),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.delete_outline, size: 22, color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color primaryColor, {bool isSearch = false}) {
    return Stack(
      children: [
        // Dekorasi latar belakang
        Positioned(top: 50, right: -50, child: Container(width: 200, height: 200, decoration: const BoxDecoration(color: Color(0xFF1E5A4A), shape: BoxShape.circle))),
        Positioned(top: 200, left: -40, child: Container(width: 180, height: 180, decoration: const BoxDecoration(color: Color(0xFF4AB393), shape: BoxShape.circle))),
        
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSearch ? Icons.search_off : Icons.shopping_bag_outlined, size: 70, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                isSearch ? "Produk tidak ditemukan" : "Belum ada produk",
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
              ),
              const SizedBox(height: 30),
              if (!isSearch)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormPage())),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
                      ),
                      child: Text("Tambah Sekarang", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14, color: primaryColor)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, MarketplaceProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Produk?", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: const Text("Produk yang dihapus tidak dapat dikembalikan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteProduct(id);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produk dihapus")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}