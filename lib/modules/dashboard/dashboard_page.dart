// lib/modules/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

// Pages
import 'pages/buyer_home_page.dart'; 
import 'pages/admin_home_page.dart'; 

import '../Seller/seller_home_page.dart'; 
import '../Seller/seller_product_list_page.dart';
import '../Seller/seller_order_page.dart';

import '../marketplace/pages/produk_list_page.dart';
import '../history/pages/transaction_history_page.dart';
import '../profile/pages/account_page.dart';
import '../data/pages/user_page.dart'; 
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

  // Fungsi untuk mengubah tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _setupMenuByRole(String? role) {
    if (role == 'admin') {
      // MENU ADMIN
      _pages = [
        const AdminHomePage(),
        const UserListPage(),
        const ProdukListPage(),
        const AccountPage(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produk'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
      ];
    } else if (role == 'penjual') {
      // MENU PENJUAL
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
    } else {
      // MENU PEMBELI
      _pages = [
        // --- DISINI PERUBAHANNYA ---
        // Kita kirim fungsi untuk pindah ke index 1 (Shop)
        BuyerHomePage(
          onGoToShop: () => _onItemTapped(1), 
        ),
        // ---------------------------
        const ProdukListPage(), 
        const TransactionHistoryPage(), 
        const AccountPage(), 
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
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.userRole;
    
    _setupMenuByRole(role);

    if (_selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }

    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      
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
          : null, 
      
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