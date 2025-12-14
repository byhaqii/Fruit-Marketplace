// lib/modules/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

// --- IMPORT PAGES BY ROLE ---

// 1. ADMIN
import 'pages/admin_home_page.dart';
import '../Data/pages/user_page.dart'; // Halaman User List (Admin)

// 2. SELLER
import '../Seller/seller_home_page.dart';
import '../Seller/seller_product_list_page.dart';
import '../Seller/seller_order_page.dart';

// 3. BUYER
import 'pages/buyer_home_page.dart';
import '../marketplace/pages/produk_list_page.dart';
import '../history/pages/transaction_history_page.dart';

// 4. SHARED
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

  // Helper to normalize role check (case-insensitive)
  bool _isRole(String? userRole, List<String> targetRoles) {
    if (userRole == null) return false;
    return targetRoles.contains(userRole.toLowerCase());
  }

  void _setupMenuByRole(String? role) {
    // Reset menu
    _pages = [];
    _navItems = [];

    if (_isRole(role, ['admin'])) {
      // ==========================
      // ADMIN MENU
      // ==========================
      _pages = [
        const AdminHomePage(),
        const UserListPage(),
        const ProdukListPage(), // Admin uses buyer Marketplace list UI
        const AccountPage(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ];
    } else if (_isRole(role, ['penjual', 'seller', 'pedagang'])) {
      // ==========================
      // SELLER MENU
      // ==========================
      _pages = [
        const SellerHomePage(),
        SellerProductListPage(),
        const SellerOrderPage(),
        const AccountPage(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Products'),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ];
    } else {
      // ==========================
      // BUYER MENU (DEFAULT)
      // ==========================
      _pages = [
        BuyerHomePage(
          onGoToShop: () =>
              setState(() => _selectedIndex = 1), // Switch to Shop tab
        ),
        const ProdukListPage(),
        const ScanPage(),
        const TransactionHistoryPage(),
        const AccountPage(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // 1. Setup menu based on role at build
    _setupMenuByRole(user?.role);

    // 2. Safety check index (prevents range errors when switching accounts/roles)
    if (_selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }

    // Warna Utama Aplikasi
    const Color primaryColor = Color(0xFF2D7F6A);

    return Scaffold(
      // MAIN NAVIGATION LOGIC:
      body: _pages.isNotEmpty
          ? IndexedStack(index: _selectedIndex, children: _pages)
          : const Center(child: CircularProgressIndicator()),

      // BOTTOM NAVIGATION BAR (Shown for all roles)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navItems,
        type: BottomNavigationBarType.fixed, // Keep labels when items > 3
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
}
