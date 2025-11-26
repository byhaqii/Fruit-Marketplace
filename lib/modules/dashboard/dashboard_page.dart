// lib/modules/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

// --- IMPORT PAGE BERDASARKAN ROLE ---

// 1. ADMIN
import 'pages/admin_home_page.dart'; 
import '../Data/pages/user_page.dart'; // Halaman User List (Admin)

// 2. PENJUAL (SELLER)
import '../Seller/seller_home_page.dart'; 
import '../Seller/seller_product_list_page.dart';
import '../Seller/seller_order_page.dart';

// 3. PEMBELI (BUYER)
import 'pages/buyer_home_page.dart'; 
import '../marketplace/pages/produk_list_page.dart';
import '../history/pages/transaction_history_page.dart';

// 4. UMUM (SHARED)
import '../profile/pages/account_page.dart';
import '../scan/pages/scan_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];
  List<BottomNavigationBarItem> _navItems = [];

  // Helper untuk normalisasi cek role (case insensitive)
  bool _isRole(String? userRole, List<String> targetRoles) {
    if (userRole == null) return false;
    return targetRoles.contains(userRole.toLowerCase());
  }

  void _setupMenuByRole(String? role) {
    // Reset menu
    _pages = [];
    _navItems = [];

    if (_isRole(role, ['admin',])) {
      // ==========================
      // MENU ADMIN
      // ==========================
      _pages = [
        const AdminHomePage(),
        const UserListPage(),
        const SellerProductListPage(), // Admin bisa liat semua produk (reuse page)
        const AccountPage(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produk'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
      ];
    } 
    else if (_isRole(role, ['penjual', 'seller', 'pedagang'])) {
      // ==========================
      // MENU PENJUAL (SELLER) - FIX: ADA BOTTOM BAR
      // ==========================
      _pages = [
        const SellerHomePage(),
        const SellerProductListPage(),
        const SellerOrderPage(),
        const AccountPage(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Toko'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Produk'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
      ];
    } 
    else {
      // ==========================
      // MENU PEMBELI (DEFAULT)
      // ==========================
      _pages = [
        BuyerHomePage(
          onGoToShop: () => setState(() => _selectedIndex = 1), // Pindah ke tab Shop
        ),
        const ProdukListPage(), 
        const ScanPage(),
        const TransactionHistoryPage(), 
        const AccountPage(), 
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Belanja'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // 1. Setup Menu Berdasarkan Role saat build
    _setupMenuByRole(user?.role);

    // 2. Safety Check Index (Mencegah error range error saat ganti akun beda role)
    if (_selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }

    // Warna Utama Aplikasi
    const Color primaryColor = Color(0xFF2D7F6A);

    return Scaffold(
      // LOGIKA NAVIGASI UTAMA:
      body: _pages.isNotEmpty 
          ? IndexedStack(index: _selectedIndex, children: _pages)
          : const Center(child: CircularProgressIndicator()),
      
      // BOTTOM NAVIGATION BAR (Muncul untuk SEMUA role)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navItems,
        type: BottomNavigationBarType.fixed, // Agar label tetap muncul jika item > 3
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
      ),
    );
  }
}