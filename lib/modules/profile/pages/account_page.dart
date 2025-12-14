// lib/modules/profile/pages/account_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../auth/pages/login_page.dart';
import '../../../config/env.dart'; // <<< Tambahkan import Env

// Import Halaman Sub-Menu
import 'setting_page.dart';
import 'profile_page.dart';
import 'aboutus_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  // Konstanta Warna
  static const Color gradientStart = Color(0xFF2D7F6A);
  static const Color gradientEnd = Color(0xFF51E5BF);
  static const Color primaryText = Color(0xFF2D7F6A);
  static const Color accentPurple = Color(0xFF8979FF);
  static const Color accentOrange = Color(0xFFFF9800);

  // --- Helper URL Baru ---
  String _getStorageBaseUrl() {
    return Env.apiBaseUrl.replaceFirst('/api', '');
  }

  String getAvatarUrl(String? filename) {
    if (filename == null || filename.isEmpty) return '';

    return '${_getStorageBaseUrl()}/storage/profiles/$filename';
  }
  // -----------------------

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;

    // Jika data user belum siap/loading
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Tentukan sumber gambar avatar
    final String? avatarFilename = user.avatar;
    final bool hasAvatar = avatarFilename != null && avatarFilename.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. HEADER GRADIENT BACKGROUND
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [gradientStart, gradientEnd],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // 2. CONTENT CONTAINER (PUTIH)
          Positioned.fill(
            top: 190,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 90), // Ruang untuk Avatar
                child: Column(
                  children: [
                    // --- MENU OPTIONS ---
                    _buildMenuButton(
                      context,
                      title: "My Profile",
                      icon: Icons.person_outline,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      ),
                    ),
                    _buildMenuButton(
                      context,
                      title: "Change Password",
                      icon: Icons.lock_outline,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingPage()),
                      ),
                    ),
                    _buildMenuButton(
                      context,
                      title: "About Us",
                      icon: Icons.info_outline,
                      onTap: () {
                        // PERUBAHAN: Navigasi ke AboutUsPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutUsPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // --- LOGOUT BUTTON ---
                    _buildMenuButton(
                      context,
                      title: "Logout",
                      icon: Icons.logout,
                      isLogout: true,
                      onTap: () => _handleLogout(context, authProvider),
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      "Versi 1.0.0",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // 3. FLOATING PROFILE INFO (AVATAR + NAMA)
          Positioned(
            top: 130,
            left: 30,
            right: 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // AVATAR - FIX DITERAPKAN DI SINI
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Gradient Ring behind avatar
                    Container(
                      width: 142,
                      height: 142,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [accentPurple, accentOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                        color: Colors.grey[300],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        image: hasAvatar
                            ? DecorationImage(
                                image: NetworkImage(
                                  getAvatarUrl(avatarFilename),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: hasAvatar
                          ? null
                          : const Icon(
                              Icons.person,
                              size: 62,
                              color: Colors.white,
                            ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // NAMA & EMAIL
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (user.role == 'pedagang' ||
                                user.role == 'penjual')
                              const Icon(
                                Icons.store_rounded,
                                color: Colors.white,
                                size: 22,
                              )
                            else
                              const Icon(
                                Icons.verified_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        // Small chips to show role/status
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryText.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.badge_rounded,
                                    color: primaryText,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user.role ?? 'User',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black12.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.privacy_tip_rounded,
                                    color: Colors.black54,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Secure',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    // ... (widget _buildMenuButton tetap sama)
    return Container(
      width: double.infinity,
      height: 58,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: isLogout
            ? LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.08),
                  Colors.red.withOpacity(0.14),
                ],
              )
            : LinearGradient(
                colors: [
                  primaryText.withOpacity(0.08),
                  primaryText.withOpacity(0.14),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: isLogout ? Colors.red : primaryText,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isLogout ? Colors.red : primaryText,
                  ),
                ),
                if (!isLogout) ...[
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.black38,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirm) return;

    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }
}
