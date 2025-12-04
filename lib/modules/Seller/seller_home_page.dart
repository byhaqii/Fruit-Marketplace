// lib/modules/Seller/seller_home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/produk_model.dart'; // Import ini dibutuhkan untuk List<ProdukModel>

// --- IMPORT HALAMAN NAVIGASI ---
import 'seller_product_list_page.dart';
import 'seller_order_page.dart'; 
import '../keuangan/pages/laporan_page.dart'; 
import '../profile/pages/account_page.dart'; 
import '../notification/pages/notification_page.dart'; 

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  static const Color primaryColor = Color(0xFF2D7F6A);

  @override
  void initState() {
    super.initState();
    // Refresh data saat dashboard dibuka
    Future.microtask(() {
      Provider.of<MarketplaceProvider>(context, listen: false).fetchAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    // PERBAIKAN: Menggunakan Consumer2 untuk mengakses MarketplaceProvider dan AuthProvider
    return Consumer2<MarketplaceProvider, AuthProvider>(
      builder: (context, provider, authProvider, child) {
        
        final user = authProvider.user; // Ambil data user
        
        // PERBAIKAN KRUSIAL: Konversi ID pengguna (String) ke int dengan aman
        final int? currentUserId = int.tryParse(user?.id ?? '');
        
        // 1. Filter produk yang dimiliki oleh penjual yang sedang login
        List<ProdukModel> sellerProducts = [];
        if (currentUserId != null) {
          // Asumsi: provider.products berisi SEMUA produk (dari fetchProducts())
          sellerProducts = provider.products.where((p) => p.userId == currentUserId).toList();
        }

        // 2. Hitung statistik dari data yang sudah difilter
        final int totalProduk = sellerProducts.length; 
        final int pesananBaru = provider.incomingOrders.length; 
        final bool isLoading = provider.isLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: const Text(
              'Dashboard Penjual', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              // 1. TOMBOL NOTIFIKASI
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const NotificationPage())
                  );
                },
                icon: const Icon(Icons.notifications, color: Colors.white), 
              ),
              // 2. TOMBOL REFRESH
              IconButton(
                onPressed: () {
                   provider.fetchAllData();
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Data diperbarui"))
                   );
                },
                icon: const Icon(Icons.refresh, color: Colors.white), 
              )
            ],
          ),
          
          body: isLoading 
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER WELCOME
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryColor, Color(0xFF4DB6AC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront, color: Colors.white, size: 40),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, ${user?.name ?? "Juragan"}!',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                const Text('Kelola tokomu dengan mudah.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // STATISTIK RINGKAS
                    const Text("Ringkasan Toko", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard("Pesanan Baru", pesananBaru.toString(), Icons.receipt_long, Colors.orange)),
                        const SizedBox(width: 15),
                        // totalProduk kini sudah difilter
                        Expanded(child: _buildStatCard("Total Produk", totalProduk.toString(), Icons.inventory_2, Colors.blue)),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // MENU UTAMA (GRID)
                    const Text("Menu Cepat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.1,
                      children: [
                        _buildMenuButton(
                          context, 
                          title: "Produk Saya", 
                          icon: Icons.add_box_outlined, 
                          color: primaryColor,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerProductListPage())),
                        ),
                        _buildMenuButton(
                          context, 
                          title: "Pesanan Masuk", 
                          icon: Icons.list_alt, 
                          color: Colors.orange,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerOrderPage())),
                        ),
                        _buildMenuButton(
                          context, 
                          title: "Laporan", 
                          icon: Icons.bar_chart, 
                          color: Colors.purple,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanPage())),
                        ),
                        // UPDATE: Mengarah ke AccountPage
                        _buildMenuButton(
                          context, 
                          title: "Akun Toko", 
                          icon: Icons.person_outline, 
                          color: Colors.grey,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountPage())),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 80), 
                  ],
                ),
              ),
        );
      }
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}