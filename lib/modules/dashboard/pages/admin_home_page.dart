// lib/modules/dashboard/pages/admin_home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.redAccent, // Warna pembeda Admin
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Admin ${user?.name ?? ''}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Grid Menu Cepat
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildAdminCard(
                  icon: Icons.people,
                  title: 'Manajemen User',
                  color: Colors.blue,
                  onTap: () {
                    // Navigasi ke tab user (index 1 di dashboard page)
                    // Note: Ini butuh trik khusus atau biarkan user klik tab bawah
                  },
                ),
                _buildAdminCard(
                  icon: Icons.monetization_on,
                  title: 'Laporan Keuangan',
                  color: Colors.green,
                  onTap: () {},
                ),
                _buildAdminCard(
                  icon: Icons.inventory,
                  title: 'Semua Produk',
                  color: Colors.orange,
                  onTap: () {},
                ),
                _buildAdminCard(
                  icon: Icons.settings,
                  title: 'Pengaturan',
                  color: Colors.grey,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}