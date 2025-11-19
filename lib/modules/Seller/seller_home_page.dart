// lib/modules/dashboard/pages/seller_home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import Provider (Perhatikan jumlah ../ disesuaikan dengan struktur folder)
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';

// Halaman Navigasi
import 'seller_product_list_page.dart';
import '../history/pages/transaction_history_page.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  
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
    final user = Provider.of<AuthProvider>(context).user;
    final provider = Provider.of<MarketplaceProvider>(context);
    
    final int totalProduk = provider.products.length; 
    final int pesananBaru = provider.incomingOrders.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        // 1. JUDUL DIBUAT PUTIH
        title: const Text(
          'Dashboard Penjual', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // <--- EKSPLISIT PUTIH
          )
        ),
        backgroundColor: Colors.teal,
        // 2. ICON THEME (Agar tombol back/menu jadi putih)
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
               provider.fetchAllData();
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text("Data diperbarui"))
               );
            },
            // 3. ICON REFRESH DIBUAT PUTIH
            icon: const Icon(Icons.refresh, color: Colors.white), 
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER WELCOME
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.teal, Color(0xFF4DB6AC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront, color: Colors.white, size: 40),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${user?.name ?? "Juragan"}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Kelola tokomu dengan mudah.',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 2. STATISTIK RINGKAS
            const Text("Ringkasan Toko", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Pesanan", 
                    pesananBaru.toString(), 
                    Icons.receipt_long, 
                    Colors.orange
                  )
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    "Produk", 
                    totalProduk.toString(), 
                    Icons.inventory_2, 
                    Colors.blue
                  )
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 3. MENU UTAMA (GRID)
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
                  color: Colors.teal,
                  onTap: () {
                    // UBAH KE SINI:
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const SellerProductListPage()) 
                    );
                  },
                ),
                _buildMenuButton(
                  context, 
                  title: "Pesanan Masuk", 
                  icon: Icons.list_alt, 
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const TransactionHistoryPage())
                    );
                  },
                ),
                _buildMenuButton(
                  context, 
                  title: "Laporan", 
                  icon: Icons.bar_chart, 
                  color: Colors.purple,
                  onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Fitur Laporan Segera Hadir"))
                     );
                  },
                ),
                _buildMenuButton(
                  context, 
                  title: "Pengaturan", 
                  icon: Icons.settings, 
                  color: Colors.grey,
                  onTap: () {
                    // Opsional: Navigasi ke halaman pengaturan
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
          ),
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
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}