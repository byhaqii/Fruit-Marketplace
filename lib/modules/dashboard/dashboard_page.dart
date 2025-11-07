// lib/modules/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
// import '../../widgets/sidebar.dart'; // Menghapus import Sidebar
import '../../widgets/bottombar.dart'; 

// Mengubah menjadi StatefulWidget untuk mengelola status navigasi bawah
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 0: Home, 1: Store, 2: Statistic, 3: Akun
  int _selectedIndex = 0; 

  // Daftar halaman/konten placeholder 
  final List<Widget> pages = [
    const Center(child: Text('Halaman Home')),
    const Center(child: Text('Halaman Marketplace')),
    const Center(child: Text('Halaman Statistic')),
    const Center(child: Text('Halaman Akun')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // Properti 'drawer' dihapus karena tidak ada di mockup
      

      // 2. Floating Action Button (FAB) untuk 'Scan'
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Membuka Fitur Scan...')),
          );
        },
        // Membuat FAB menjadi Kotak/Persegi Panjang Melengkung seperti di gambar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), 
        ),
        backgroundColor: primaryColor,
        elevation: 4.0,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
      ),
      
      // 3. Lokasi FAB: di tengah dan menempel ke BottomBar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // 4. Bottom Navigation Bar
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}