import 'package:flutter/material.dart';

// Model sederhana untuk item menu admin
class AdminMenuItem {
  final String title;
  final IconData icon;
  final String routeName; // Rute yang akan dituju

  AdminMenuItem({required this.title, required this.icon, required this.routeName});
}

class AdminControlPanel extends StatelessWidget {
  const AdminControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisikan menu-menu Anda
    final List<AdminMenuItem> menuItems = [
      AdminMenuItem(title: 'Manajemen Pengguna', icon: Icons.person_pin_rounded, routeName: '/manage-users'),
      AdminMenuItem(title: 'Manajemen RW', icon: Icons.location_city, routeName: '/manage-rw'),
      AdminMenuItem(title: 'Manajemen RT', icon: Icons.holiday_village, routeName: '/manage-rt'),
      AdminMenuItem(title: 'Manajemen Keluarga', icon: Icons.family_restroom, routeName: '/manage-keluarga'),
      AdminMenuItem(title: 'Manajemen Warga', icon: Icons.people_alt, routeName: '/warga'), // Menggunakan rute warga yang ada
      AdminMenuItem(title: 'Manajemen Jenis Iuran', icon: Icons.receipt_long, routeName: '/manage-iuran'),
      AdminMenuItem(title: 'Database Tagihan', icon: Icons.storage, routeName: '/manage-tagihan'),
      AdminMenuItem(title: 'Verifikasi Pembayaran', icon: Icons.verified_user, routeName: '/verifikasi-bayar'),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 kolom
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.2, // Sesuaikan rasio agar pas
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () {
              // Pastikan Anda sudah mendaftarkan rute ini di routes.dart
              Navigator.pushNamed(context, item.routeName);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}