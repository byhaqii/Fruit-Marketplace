// lib/modules/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import '../../widgets/bottombar.dart';
import '../marketplace/pages/produk_list_page.dart'; // pastikan folder 'pages' sesuai struktur Anda

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 0: Home, 1: Store (Marketplace), 2: Statistic, 3: Akun
  int _selectedIndex = 1; // Marketplace tampilkan secara default

  // Daftar halaman sesuai urutan di BottomBar
  final List<Widget> _pages = const [
    Center(child: Text('Halaman Home')),
    ProdukListPage(), // Marketplace
    Center(child: Text('Halaman Statistic')),
    Center(child: Text('Halaman Akun')),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
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
