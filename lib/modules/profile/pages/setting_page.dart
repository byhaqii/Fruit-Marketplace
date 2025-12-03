// lib/modules/profile/pages/setting_page.dart

import 'package:flutter/material.dart';

// ==========================================
// CONSTANTS & THEME (Dari Kode Lama)
// ==========================================
const Color kPrimaryColor = Color(0xFF2D7F6A);
const Color kSecondaryColor = Color(0xFF51E5BF);
const Color kBackgroundColor = Color(0xFFF5F6FA);
const Color kInputFillColor = Color(0xFFF0F3F6);

// ==========================================
// MAIN SETTING PAGE (Kode Baru)
// ==========================================
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

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
            color: Colors.black,
          ),
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
                color: kPrimaryColor, // Menggunakan kPrimaryColor agar konsisten
              ),
            ),
            const SizedBox(height: 20),

            // Menu Ganti Password
            _buildSettingItem(
              context,
              title: 'Change Password',
              icon: Icons.lock_outline,
              onTap: () {
                // LOGIKA: Navigasi ke Halaman ChangePasswordPage (Tampilan Lama)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage()),
                );
              },
            ),

            // Menu lain bisa ditambahkan di sini
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
        // Background hijau transparan
        color: kPrimaryColor.withOpacity(0.1),
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
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}

// ==========================================
// CHANGE PASSWORD PAGE (Tampilan Dari Kode Lama)
// ==========================================
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          // HEADER
          SafeArea(
            child: Container(
              height: 180,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // BODY
          Container(
            margin: const EdgeInsets.only(top: 140),
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.black87),
                      SizedBox(width: 10),
                      Text(
                        "Change Password",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(),
                  ),
                  const Text(
                    "Your password must be at least 6 characters and should include a combination of numbers, letters and special characters (!\$@%)",
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 25),
                  _buildPasswordField("Current password"),
                  const SizedBox(height: 15),
                  _buildPasswordField("New password"),
                  const SizedBox(height: 15),
                  _buildPasswordField("Re-type new password"),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Password changed successfully!')),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("Save",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String hint) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: kPrimaryColor),
        ),
      ),
    );
  }
}