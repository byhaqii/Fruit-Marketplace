// lib/modules/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

// Pages
import 'dashboard_content_page.dart'; // Home Pembeli
import 'pages/admin_home_page.dart'; // Home Admin (BARU)
import 'pages/seller_home_page.dart'; // Home Penjual (BARU)

import '../marketplace/pages/produk_list_page.dart';
import '../history/pages/transaction_history_page.dart';
import '../profile/pages/account_page.dart';
import '../data/pages/user_page.dart'; // Halaman User (Admin)
import '../scan/pages/scan_page.dart'; // Scan QR

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // List halaman dinamis
  List<Widget> _pages = [];
  // List menu navigasi dinamis
  List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi awal (akan di-update di didChangeDependencies/build)
  }

  // Fungsi untuk mengubah tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk menyusun menu berdasarkan Role
  void _setupMenuByRole(String? role) {
    if (role == 'admin') {
      // === MENU ADMIN ===
      _pages = [
        const AdminHomePage(), // Dashboard Admin
        const UserListPage(), // Manajemen User
        const ProdukListPage(), // Manajemen Semua Produk
        const AccountPage(), // Profil
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produk'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
      ];
    } else if (role == 'penjual') {
      // === MENU PENJUAL ===
      _pages = [
        const SellerHomePage(), // Dashboard Penjual
        const ProdukListPage(), // Produk Saya
        const TransactionHistoryPage(), // Pesanan Masuk (Perlu penyesuaian filter nanti)
        const AccountPage(), // Profil
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Toko'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Produk'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
      ];
    } else {
      // === MENU PEMBELI (Default) ===
      _pages = [
        DashboardContentPage(onSeeAllTapped: () => _onItemTapped(1)), // Home
        const ProdukListPage(), // Belanja
        const TransactionHistoryPage(), // Riwayat
        const AccountPage(), // Profil
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil role dari Provider
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.userRole;
    
    // Setup menu berdasarkan role saat ini
    _setupMenuByRole(role);

    // Pastikan index tidak out of range jika role berubah
    if (_selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }

    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      
      // Floating Action Button Khusus
      floatingActionButton: (role == 'pembeli' || role == null) 
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanPage()),
                );
              },
              shape: const CircleBorder(),
              backgroundColor: primaryColor,
              elevation: 4.0,
              child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
            )
          : null, // Admin/Penjual mungkin tidak butuh tombol scan di tengah
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _navItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}