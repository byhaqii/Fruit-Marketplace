// lib/modules/profile/pages/setting_page.dart

import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  // Warna utama aplikasi
  static const Color primaryColor = Color(0xFF2D7F6A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Setting', 
          style: TextStyle(
            fontFamily: 'Poppins', 
            fontWeight: FontWeight.bold, 
            color: Colors.black
          )
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor, // Hijau #2D7F6A
              ),
            ),
            const SizedBox(height: 20),
            
            // Menu Ganti Password
            _buildSettingItem(
              context,
              title: 'Change Password',
              icon: Icons.lock_outline,
              onTap: () {
                // LOGIKA GANTI PASSWORD (Placeholder)
                // Nanti bisa diarahkan ke halaman form ganti password
                _showChangePasswordDialog(context);
              },
            ),
            
            // Anda bisa menambahkan menu lain di sini (misal: Biometrik, 2FA, dll)
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Item Menu
  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        // Background hijau transparan (konsisten dengan AccountPage)
        color: primaryColor.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(25),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  // (Opsional) Dialog Placeholder untuk Ganti Password
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ubah Kata Sandi"),
        content: const Text("Fitur ini sedang dalam pengembangan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup", style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
}