// lib/modules/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import '../../widgets/bottombar.dart';
import '../marketplace/pages/produk_list_page.dart';
import '../profile/pages/account_page.dart';
import '../history/pages/transaction_history_page.dart'; 

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 0: Home, 1: Store (Marketplace), 2: Statistic (History), 3: Akun
  // Mengatur default ke 0 (Home)
  int _selectedIndex = 0; 

  // Daftar halaman sesuai urutan di BottomBar
  final List<Widget> _pages = const [
    Center(child: Text('Halaman Home')), // Index 0
    ProdukListPage(), // Index 1: Marketplace
    // 🌟 MENGGANTI INI
    TransactionHistoryPage(), // Index 2: History/Statistic
    AccountPage(), // Index 3: Menggunakan AccountPage
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // IndexedStack menjaga state tiap halaman saat berpindah
      body: IndexedStack(index: _selectedIndex, children: _pages),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Membuka Fitur Scan...')),
          );
        },
        // Menggunakan CircleBorder untuk FAB dock yang benar
        shape: const CircleBorder(), 
        backgroundColor: primaryColor,
        elevation: 4.0,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}