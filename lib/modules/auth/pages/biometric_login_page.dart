// lib/modules/auth/pages/biometric_login_page.dart

import 'package:flutter/material.dart';
import '../../../../widgets/loading_indicator.dart';
import '../../../core/services/biometric_service.dart';

class BiometricLoginPage extends StatefulWidget {
  const BiometricLoginPage({super.key});

  @override
  State<BiometricLoginPage> createState() => _BiometricLoginPageState();
}

class _BiometricLoginPageState extends State<BiometricLoginPage> {
  final BiometricService _biometricService = BiometricService();
  String _message = 'Memulai autentikasi biometrik...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Memulai autentikasi setelah widget selesai dibangun
    Future.microtask(() => _startBiometricAuth());
  }

  void _updateMessage(String msg, {bool loading = true}) {
    if (mounted) {
      setState(() {
        _message = msg;
        _isLoading = loading;
      });
    }
  }

  Future<void> _startBiometricAuth() async {
    _updateMessage('Memeriksa token dan otentikasi...');
    
    // 1. Cek apakah ada token yang tersimpan
    final userRole = await _biometricService.getTokenAndRole();

    if (userRole == null) {
      _updateMessage('Anda harus Login manual sekali terlebih dahulu.', loading: false);
      // Tunggu 3 detik lalu kembali ke Login Page
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) Navigator.pop(context);
      return;
    }

    // 2. Memulai Biometrik
    final isAuthenticated = await _biometricService.authenticate();

    if (isAuthenticated) {
      _updateMessage('Autentikasi Berhasil! Masuk sebagai $userRole.', loading: false);
      // Navigasi ke Dashboard
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        // Menggantikan seluruh stack navigasi
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } else {
      _updateMessage('Autentikasi gagal. Silakan coba lagi atau Login manual.', loading: false);
      // Beri opsi untuk kembali ke login manual
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) const LoadingIndicator(),
            const SizedBox(height: 20),
            Text(
              _message, 
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 40),
            if (!_isLoading)
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.keyboard_backspace),
                label: const Text('Kembali ke Login Manual'),
              ),
          ],
        ),
      ),
    );
  }
}