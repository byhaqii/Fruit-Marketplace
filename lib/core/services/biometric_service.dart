// lib/core/services/biometric_service.dart
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../storage/preferences_helper.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // 1. Cek apakah ada token yang tersimpan (user pernah login)
  Future<bool> hasStoredCredentials() async {
    final token = await PreferencesHelper.getAuthToken();
    return token != null;
  }

  // 2. Cek apakah perangkat keras didukung
  Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  // 3. Panggil prompt autentikasi (INI YANG ANDA SEBUT "PENDAFTARAN")
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Konfirmasi sidik jari/wajah Anda untuk mengaktifkan fitur ini',
        options: const AuthenticationOptions(
          stickyAuth: true, // Tetap di layar sampai berhasil/gagal
          biometricOnly: true, // Hanya izinkan Biometrik (bukan PIN)
        ),
      );
    } on PlatformException catch (e) {
      // Handle error (misal: sensor tidak tersedia, dll)
      print(e);
      return false;
    }
  }

  // 4. Ambil role jika autentikasi berhasil
  Future<String?> getRoleAfterAuth() async {
    return await PreferencesHelper.getUserRole();
  }
}