// lib/modules/auth/pages/biometric_login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/biometric_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/loading_indicator.dart';

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
    _updateMessage('Pindai sidik jari/wajah Anda...');
    
    // 1. Cek apakah perangkat keras didukung
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (!isAvailable) {
      _updateMessage('Perangkat biometrik tidak tersedia. Silakan login manual.', loading: false);
      return; // Tetap di halaman ini, biarkan user tekan "Login Manual"
    }

    // 2. Tampilkan prompt autentikasi
    final isAuthenticated = await _biometricService.authenticate();

    if (isAuthenticated) {
      _updateMessage('Autentikasi Berhasil!', loading: false);
      
      // Set sesi sebagai aktif
      if (mounted) {
        // (AuthCheck akan otomatis mengarahkan ke Dashboard)
        await Provider.of<AuthProvider>(context, listen: false).setAuthenticated(true);
      }
    } else {
      _updateMessage('Autentikasi gagal. Silakan coba lagi.', loading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                color: Theme.of(context).colorScheme.primary,
                size: 64,
              ),
              const SizedBox(height: 20),
              Text(
                _message, 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Tombol untuk mencoba lagi
              if (!_isLoading)
                TextButton.icon(
                  onPressed: _startBiometricAuth,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              
              // Tombol untuk kembali ke login manual
              TextButton(
                onPressed: () {
                  // Kembali ke AuthCheck, yang akan mengarahkan ke LoginPage
                  Provider.of<AuthProvider>(context, listen: false).disableBiometrics();
                },
                child: const Text('Gunakan Password Saja'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}