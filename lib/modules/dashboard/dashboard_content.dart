// lib/modules/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../keuangan/pages/laporan_page.dart';
import '../marketplace/pages/produk_list_page.dart';
import '../notification/notification_page.dart';
import '../warga/pages/warga_list_page.dart';
import 'dashboard_content.dart'; // Nanti kita buat file ini
// import page yang dibutuhkan
import '../keuangan/pages/iuran_page.dart';

// Definisi Struktur Menu per Role
class NavItem {
  final IconData icon;
  final String label;
  final Widget screen;

  NavItem(this.icon, this.label, this.screen);
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  // --- LOGIC BOTTOM NAV BAR PER ROLE ---
  List<NavItem> _getNavItems(String? role) {
    // 1. RT / RW (Admin Toko)
    if (role == 'ketua_rt' || role == 'admin' || role == 'ketua_rw') {
      return [
        NavItem(Icons.dashboard, 'Dashboard', const DashboardContent()),
        NavItem(Icons.apple, 'Produk', const ProdukListPage()), // Kelola Produk
        NavItem(Icons.account_balance_wallet_outlined, 'Keuangan', const LaporanPage()), // Pantau Laporan & Transaksi
        NavItem(Icons.group, 'Tim', const WargaListPage()), // Kelola Sekretaris & Bendahara (Asumsi pakai Warga List)
        NavItem(Icons.person, 'Akun', const Placeholder()),
      ];
    }
    
    // 2. Sekretaris
    if (role == 'sekretaris') {
      return [
        NavItem(Icons.inventory_2_outlined, 'Produk', const ProdukListPage()), // Update Stok/Buah Baru
        NavItem(Icons.list_alt, 'Pesanan', const WargaListPage()), // Cek dan proses pesanan
        NavItem(Icons.bar_chart, 'Statistik', const LaporanPage()), // Lihat penjualan
        NavItem(Icons.person, 'Akun', const Placeholder()),
      ];
    }

    // 3. Bendahara
    if (role == 'bendahara') {
      return [
        NavItem(Icons.monetization_on_outlined, 'Keuangan', const IuranPage()), // Input & verifikasi transaksi (Iuran Page)
        NavItem(Icons.receipt_long, 'Laporan', const LaporanPage()), // Generate laporan penjualan
        NavItem(Icons.shopping_bag_outlined, 'Pesanan', const WargaListPage()), // Cek pembayaran warga
        NavItem(Icons.person, 'Akun', const Placeholder()),
      ];
    }

    // 4. Warga (Pembeli) - Default
    return [
      NavItem(Icons.home_outlined, 'Home', const DashboardContent()), // Promo & Rekomendasi
      NavItem(Icons.storefront_outlined, 'Store', const ProdukListPage()), // Beli Buah
      NavItem(Icons.qr_code_scanner, 'Scan', const Placeholder()), // AI Fruit Scanner
      NavItem(Icons.history, 'Riwayat', const WargaListPage()), // Riwayat Pembelian
      NavItem(Icons.person, 'Akun', const Placeholder()),
    ];
  }
  // --- END LOGIC BOTTOM NAV BAR ---


  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final navItems = _getNavItems(auth.userRole);
        
        return Scaffold(
          // AppBar kosong atau minimal (sesuai gaya Bottom Nav)
          appBar: AppBar(
            title: Text(AppConstants.appName, style: Theme.of(context).appBarTheme.titleTextStyle),
            automaticallyImplyLeading: false, // Hapus tombol back
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                onPressed: () async {
                  await auth.logout();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ],
          ),

          // Body akan menampilkan screen yang dipilih dari Nav Items
          body: navItems[_currentIndex].screen,
          
          // Bottom Navigation Bar
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            backgroundColor: Colors.white,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: navItems.map((item) {
              return BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// Tambahkan file DashboardContent (sebelumnya DashboardPage)
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome to ${AppConstants.appName}!', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          Text('Role Anda: ${auth.userRole}', style: const TextStyle(fontSize: 18, color: Colors.blueGrey)),
          const SizedBox(height: 30),
          // Tambahkan statistik/widget dashboard spesifik di sini
        ],
      ),
    );
  }
}