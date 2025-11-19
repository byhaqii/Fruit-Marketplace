// lib/modules/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import '../../widgets/bottombar.dart';
import '../marketplace/pages/produk_list_page.dart';
import '../profile/pages/account_page.dart';
import 'dashboard_content_page.dart';
import '../scan/pages/scan_page.dart';

// --- PERUBAHAN DI SINI ---
// import '../history/pages/transaction_history_page.dart'; // DI-COMMENT (ASLI)
// import '../keuangan/pages/keuangan_page.dart'; // DI-COMMENT (PERMINTAAN SEBELUMNYA)
// Ganti path ini sesuai lokasi file UserListPage Anda
import '../data/pages/user_page.dart'; // BENAR // DITAMBAHKAN TAMPILAN USER
// --- BATAS PERUBAHAN ---


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardContentPage(onSeeAllTapped: () => _onItemTapped(1)),
      const ProdukListPage(),

      // --- PERUBAHAN DI SINI ---
      // const TransactionHistoryPage(), // DI-COMMENT (ASLI)
      // const KeuanganPage(), // DI-COMMENT (PERMINTAAN SEBELUMNYA)
      const UserListPage(), // DITAMBAHKAN TAMPILAN USER
      // --- BATAS PERUBAHAN ---

      const AccountPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        child: BottomBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}