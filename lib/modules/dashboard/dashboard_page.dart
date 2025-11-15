// lib/modules/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import '../../widgets/bottombar.dart';
import '../marketplace/pages/produk_list_page.dart';
import '../profile/pages/account_page.dart';
// import '../history/pages/transaction_history_page.dart'; // DI-COMMENT
import '../keuangan/pages/keuangan_page.dart'; // DITAMBAHKAN
import 'dashboard_content_page.dart';
import '../scan/pages/scan_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // UBAH 1: Hapus 'const' dan buat 'late final'
  late final List<Widget> _pages;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  // UBAH 2: Tambahkan initState untuk mendefinisikan _pages
  @override
  void initState() {
    super.initState();
    _pages = [
      // Kirim fungsi _onItemTapped(1) sebagai callback
      DashboardContentPage(onSeeAllTapped: () => _onItemTapped(1)),
      const ProdukListPage(),
      // const TransactionHistoryPage(), // DI-COMMENT
      const KeuanganPage(), // DITAMBAHKAN
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
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}