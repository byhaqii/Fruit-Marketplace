// file: account_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- DITAMBAHKAN
import '../profile_page.dart';
import '../settings_page.dart';
// import 'transaction_history_page.dart'; // <-- DI-COMMENT, file tidak ada
import '../../../providers/auth_provider.dart'; // <-- DITAMBAHKAN

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  // Warna utama
  static const Color primaryGreen = Color.fromARGB(255, 56, 142, 60);

  // Konstanta ukuran layout
  static const double _headerHeight = 150;
  static const double _avatarRadius = 46;
  static const double _avatarTopOverlap = 20;
  static const double _textStartPadding = 16.0;
  static const double _avatarLeftPadding = 20;

  @override
  Widget build(BuildContext context) {
    // AMBIL DATA DARI PROVIDER, BUKAN DUMMY
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Mengikuti logika dari profile_page.dart, kita gunakan role sebagai nama
    final String userName = auth.userRole ?? 'Pengguna';
    final String userEmail = 'Role: ${auth.userRole ?? 'N/A'}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + Avatar + Nama & Email
            // Kirim data string, bukan UserModel
            _buildHeaderWithCombinedInfo(userName, userEmail),

            // Menu utama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildMenuTile(
                    context,
                    title: 'My Profile',
                    icon: Icons.person_outline,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ),
                  ),
                  _buildMenuTile(
                    context,
                    title: 'Setting',
                    icon: Icons.settings_outlined,
                    onTap: () => Navigator.push(
                      context,
                      // Menggunakan SettingsPage, bukan SettingPage
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                  // _buildMenuTile( // <-- DI-COMMENT KARENA FILE IMPORT TIDAK ADA
                  //   context,
                  //   title: 'Transaction History',
                  //   icon: Icons.history,
                  //   onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (_) => const TransactionHistoryPage(),
                  //     ),
                  //   ),
                  // ),
                  _buildMenuTile(
                    context,
                    title: 'About App',
                    icon: Icons.info_outline,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Aplikasi E-Commerce v1.0'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLogoutTile(context, auth), // <-- Kirim provider
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header (DIUBAH: Menerima String, bukan UserModel)
  Widget _buildHeaderWithCombinedInfo(String name, String email) {
    const double greenHeight = _headerHeight - _avatarTopOverlap;
    const double stackHeight = _headerHeight + _avatarRadius;

    final double avatarAreaWidth = (_avatarRadius * 2) + _avatarLeftPadding;
    final double textVerticalPosition = greenHeight + 10;
    const double textHorizontalOffset = 16;

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background hijau
          Container(
            height: greenHeight,
            width: double.infinity,
            color: primaryGreen,
          ),

          // Avatar
          Positioned(
            left: _avatarLeftPadding,
            top: greenHeight - _avatarRadius,
            child: const CircleAvatar(
              radius: _avatarRadius,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage('https://picsum.photos/200/200'),
            ),
          ),

          // Nama & Email (DIUBAH: Menggunakan parameter string)
          Positioned(
            top: textVerticalPosition,
            left: avatarAreaWidth + textHorizontalOffset,
            right: _textStartPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name, // <-- Menggunakan parameter 'name'
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email, // <-- Menggunakan parameter 'email'
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk setiap item menu
  Widget _buildMenuTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.black54),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget untuk tombol logout (DIUBAH: Menerima AuthProvider)
  Widget _buildLogoutTile(BuildContext context, AuthProvider auth) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () async { // <-- DIUBAH jadi async
            // LOGIKA LOGOUT SEBENARNYA DARI profile_page.dart
            await auth.logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/auth-check', (route) => false);
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.black54),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}