// file: account_page.dart
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'setting_page.dart';
import 'transaction_history_page.dart';
import '/../models/user_model.dart'; // pastikan path ini benar

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
    final UserModel user = UserModel.dummyUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + Avatar + Nama & Email
            _buildHeaderWithCombinedInfo(user),

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
                      MaterialPageRoute(builder: (_) => const SettingPage()),
                    ),
                  ),
                  _buildMenuTile(
                    context,
                    title: 'Transaction History',
                    icon: Icons.history,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransactionHistoryPage(),
                      ),
                    ),
                  ),
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
                  _buildLogoutTile(context),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header berisi background hijau, avatar, dan teks user info
  Widget _buildHeaderWithCombinedInfo(UserModel user) {
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

          // Nama & Email
          Positioned(
            top: textVerticalPosition,
            left: avatarAreaWidth + textHorizontalOffset,
            right: _textStartPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
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
                  user.email,
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

  /// Widget untuk tombol logout
  Widget _buildLogoutTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logging out...')),
            );
            // Tambahkan logika logout nyata di sini jika perlu
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
