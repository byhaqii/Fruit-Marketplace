// lib/modules/profile/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Keamanan')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Aktifkan Login Biometrik'),
                subtitle: const Text('Gunakan sidik jari/wajah untuk login lebih cepat.'),
                value: auth.isBiometricEnabled,
                onChanged: (bool newValue) async {
                  if (newValue) {
                    // Ini adalah proses "PENDAFTARAN"
                    bool success = await auth.enableBiometrics();
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal mengaktifkan biometrik.')),
                      );
                    }
                  } else {
                    // Nonaktifkan
                    await auth.disableBiometrics();
                  }
                },
              ),
              ListTile(
                title: const Text('Ganti Password'),
                leading: const Icon(Icons.lock_outline),
                onTap: () {
                  // TODO: Navigasi ke halaman ganti password
                },
              )
            ],
          );
        },
      ),
    );
  }
}