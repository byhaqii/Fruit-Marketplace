// lib/modules/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../keuangan/pages/laporan_page.dart';
import '../marketplace/pages/produk_list_page.dart';
import '../notification/notification_page.dart';
import '../warga/pages/warga_list_page.dart';
import 'dashboard_content.dart';
import '../keuangan/pages/iuran_page.dart';
import '../profile/profile_page.dart'; 
import 'admin_control_panel.dart'; 

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
  List<NavItem> _navItems = []; 
  String _appBarTitle = AppConstants.appName; 

  // --- DEFINISI GRADASI BARU DARI XML ---
  // Warna hijau primer (Offset 0.4)
  static const Color topGradientColor = Color(0xFF2D7F6A); 
  // Warna teal transparan (B3 = 70% opacity, Offset 1.0)
  static const Color bottomGradientColor = Color(0xB351E5BF); 
  // --- AKHIR DEFINISI GRADASI ---

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _navItems = _getNavItems(auth.userRole);
    
    if (auth.userRole == 'admin') {
      _appBarTitle = 'Admin Control Panel';
    } else {
      _appBarTitle = _navItems[0].label;
    }
  }

  // --- LOGIC BOTTOM NAV BAR PER ROLE ---
  List<NavItem> _getNavItems(String? role) {
    const profileScreen = ProfilePage(); 

    // 0. SUPER ADMIN (Role Baru Anda)
    if (role == 'admin') {
      return [
        NavItem(Icons.settings, 'Control Panel', const AdminControlPanel()),
        NavItem(Icons.people_alt, 'Data Warga', const WargaListPage()),
        NavItem(Icons.receipt_long, 'Laporan Keuangan', const LaporanPage()),
        NavItem(Icons.person, 'Akun', profileScreen),
      ];
    }

    // 1. RT / RW (Admin Toko)
    if (role == 'ketua_rt' || role == 'ketua_rw') {
      return [
        NavItem(Icons.dashboard, 'Dashboard', const DashboardContent()),
        NavItem(Icons.apple, 'Produk', const ProdukListPage()),
        NavItem(Icons.account_balance_wallet_outlined, 'Keuangan', const LaporanPage()),
        NavItem(Icons.group, 'Tim', const WargaListPage()),
        NavItem(Icons.person, 'Akun', profileScreen), 
      ];
    }
    
    // 2. Sekretaris
    if (role == 'sekretaris') {
      return [
        NavItem(Icons.inventory_2_outlined, 'Produk', const ProdukListPage()),
        NavItem(Icons.list_alt, 'Pesanan', const WargaListPage()),
        NavItem(Icons.bar_chart, 'Statistik', const LaporanPage()),
        NavItem(Icons.person, 'Akun', profileScreen), 
      ];
    }

    // 3. Bendahara
    if (role == 'bendahara') {
      return [
        NavItem(Icons.monetization_on_outlined, 'Keuangan', const IuranPage()),
        NavItem(Icons.receipt_long, 'Laporan', const LaporanPage()),
        NavItem(Icons.shopping_bag_outlined, 'Pesanan', const WargaListPage()),
        NavItem(Icons.person, 'Akun', profileScreen), 
      ];
    }

    // 4. Warga (Pembeli) - Default
    return [
      NavItem(Icons.home_outlined, 'Home', const DashboardContent()),
      NavItem(Icons.storefront_outlined, 'Store', const ProdukListPage()),
      NavItem(Icons.qr_code_scanner, 'Scan', const Placeholder()), // AI Fruit Scanner
      NavItem(Icons.history, 'Riwayat', const WargaListPage()),
      NavItem(Icons.person, 'Akun', profileScreen), 
    ];
  }
  // --- END LOGIC BOTTOM NAV BAR ---


  @override
  Widget build(BuildContext context) {
    final bool isAdmin = Provider.of<AuthProvider>(context, listen: false).userRole == 'admin';
    
    return Scaffold(
      // Atur AppBar agar transparan
      extendBodyBehindAppBar: true, // Membuat body menembus ke belakang AppBar
      appBar: AppBar(
        title: Text(
          _appBarTitle, 
          // Atur warna teks AppBar menjadi putih agar kontras dengan gradasi
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: Colors.white)
        ),
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.transparent, // Buat AppBar transparan
        elevation: 0, // Hapus bayangan
      ),

      // Gunakan Stack untuk menempatkan gradasi di belakang konten
      body: Stack(
        children: [
          // Layer 1: Gradasi Background (Sesuai XML Anda)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [topGradientColor, bottomGradientColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.4, 1.0], // Sesuai offset 0.4 dan 1.0
              ),
            ),
          ),
          
          // Layer 2: Konten Halaman (yang sekarang transparan)
          // Tambahkan SafeArea agar konten tidak tertutup notch/status bar
          SafeArea(
            child: _navItems[_currentIndex].screen,
          ),
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: Colors.white, // Biarkan putih agar kontras
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Update judul AppBar saat tab diganti
            if (isAdmin && index == 0) {
              _appBarTitle = 'Admin Control Panel';
            } else {
              _appBarTitle = _navItems[index].label;
            }
          });
        },
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}