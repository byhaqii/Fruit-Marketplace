// lib/modules/marketplace/pages/seller_product_list_page.dart

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
  final List<String> _statusCategories = [
    "Aktif", "Stok Rendah", "Nonaktif", "Dalam pengecekan", "Gagal", "Diblokir", "Draft"
  ];
  int _selectedStatusIndex = 0;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2D7F6A);

    return Scaffold(
      backgroundColor: primaryColor, // Background Hijau Utama
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER (Tetap Putih & Bersih)
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
                        const Text(
                          "Product Saya",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: primaryColor,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.search, color: primaryColor, size: 28),
                            const SizedBox(width: 15),
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
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Tab Kategori
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

            // 2. CONTENT AREA
            Expanded(
              child: Consumer<MarketplaceProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white));

                  final products = provider.products;

                  // EMPTY STATE
                  if (products.isEmpty) {
                    return _buildEmptyState(context, primaryColor);
                  }

                  // LIST PRODUK (DESAIN BARU)
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

  // --- WIDGET KARTU PRODUK MODERN ---
  Widget _buildProductCard(BuildContext context, ProdukModel item, MarketplaceProvider provider) {
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
          // 1. FOTO PRODUK (Besar & Rounded)
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

          // 2. INFORMASI PRODUK
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama
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
                
                // Harga
                Text(
                  item.formattedPrice,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF2D7F6A), // Hijau
                  ),
                ),
                const SizedBox(height: 10),

                // Chips Info (Stok & Kategori)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    // Stok Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "${item.stok} Stok",
                            style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // Kategori Chip (Jika ada)
                    if (item.kategori.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1), // Teal Muda
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.kategori,
                          style: const TextStyle(fontSize: 10, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Color(0xFF00695C)),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),

          // 3. TOMBOL AKSI (Edit & Delete)
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

  Widget _buildEmptyState(BuildContext context, Color primaryColor) {
    return Stack(
      children: [
        Positioned(top: 50, right: -50, child: Container(width: 200, height: 200, decoration: const BoxDecoration(color: Color(0xFF1E5A4A), shape: BoxShape.circle))),
        Positioned(top: 200, left: -40, child: Container(width: 180, height: 180, decoration: const BoxDecoration(color: Color(0xFF4AB393), shape: BoxShape.circle))),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 70, color: Colors.white),
              const SizedBox(height: 20),
              const Text("Belum ada produk", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              const SizedBox(height: 30),
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