// lib/modules/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Definisikan warna gradasi BARU dari XML Anda
  static const Color topGradientColor = Color(0xFF2D7F6A);
  static const Color bottomGradientColor = Color(0xFF51E5BF);

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer agar nama/role update jika berubah
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // Ambil nama dari user (kita simpan 'role' sebagai fallback)
        final String userName = auth.userRole ?? 'Pengguna'; 
        final String userEmail = 'Role: ${auth.userRole}';

        return Scaffold(
          body: ListView(
            padding: EdgeInsets.zero, // Hapus padding atas default dari ListView
            children: [
              // Header Profil dengan Gradasi Baru
              Container(
                padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
                decoration: const BoxDecoration(
                  // --- PERUBAHAN GRADASI DI SINI ---
                  gradient: LinearGradient(
                    colors: [topGradientColor, bottomGradientColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  // --- AKHIR PERUBAHAN ---
                  borderRadius: BorderRadius.only(
                     bottomLeft: Radius.circular(20),
                     bottomRight: Radius.circular(20),
                  )
                ),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Text(
                        userName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32.0, 
                          fontWeight: FontWeight.bold,
                          color: topGradientColor // Gunakan warna gelap untuk teks
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Nama dan Role
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName, // Tampilkan nama pengguna
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 20,
                            color: Colors.white
                          ),
                        ),
                        Text(
                          userEmail, // Tampilkan email/role
                           style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20), // Beri jarak

              // Menu Pengaturan
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Keamanan & Biometrik'),
                subtitle: const Text('Atur login sidik jari/wajah'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Edit Profil'),
                subtitle: const Text('Lengkapi NIK, KK, dan data diri'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigasi ke halaman edit profil (WargaFormPage)
                  // Navigator.pushNamed(context, '/warga-form');
                },
              ),
              const Divider(),
              // Tombol Logout
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  // Panggil fungsi logout dari provider
                  await auth.logout();
                  
                  // Navigasi kembali ke AuthCheck (yang akan mengarahkan ke Login)
                  if (context.mounted) {
                     Navigator.pushNamedAndRemoveUntil(context, '/auth-check', (route) => false);
                  }
                },
              ),
            ],
          ),
        );
      }
    );
  }
}