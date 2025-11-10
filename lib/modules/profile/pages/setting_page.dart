// file setting_page.dart
import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Privacy
            Text(
              'Privacy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Text(
              'Customize Your Privacy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Opsi 1: Biometric Login
            _buildSettingTile(
              context,
              title: 'Biometric Login',
              trailing: const Icon(Icons.fingerprint_outlined, color: Colors.black54),
              isSwitch: true,
              onTap: () {
                // Logika toggle biometric
              },
            ),
            const SizedBox(height: 16),

            // Opsi 2: Change Password
            _buildSettingTile(
              context,
              title: 'Change Password',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
              onTap: () {
                // Navigasi ke halaman ganti password
              },
            ),
            const SizedBox(height: 16),

            // Opsi 3: Logout Semua Perangkat
            _buildSettingTile(
              context,
              title: 'Logout Semua Perangkat',
              trailing: const Icon(Icons.logout, color: Colors.black54),
              onTap: () {
                // Logika logout semua perangkat
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout Semua Perangkat...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
      BuildContext context, {
      required String title,
      required Widget trailing,
      bool isSwitch = false,
      required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isSwitch ? null : onTap, // Jika switch, onTap dikelola oleh Switch
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (isSwitch)
              Switch(
                value: true, // Nilai dummy untuk switch
                onChanged: (bool value) {
                  // Logika perubahan switch
                },
                activeThumbColor: Colors.teal,
              )
            else
              trailing,
          ],
        ),
      ),
    );
  }
}