// lib/core/services/biometric_service.dart
import '../storage/preferences_helper.dart';

class BiometricService {
  // Dalam aplikasi nyata, ini akan menggunakan package seperti local_auth
  // dan mungkin memvalidasi token dengan endpoint /auth/biometric

  Future<bool> authenticate() async {
    // Simulasi proses autentikasi biometrik:
    // 1. Cek apakah perangkat mendukung biometrik (local_auth.canCheckBiometrics)
    // 2. Tampilkan prompt autentikasi (local_auth.authenticate)

    // Untuk tujuan demo, asumsikan autentikasi selalu berhasil setelah 1 detik
    await Future.delayed(const Duration(seconds: 1));
    return true; 
  }

  Future<String?> getTokenAndRole() async {
    // Mengambil token dan role dari local storage
    final token = await PreferencesHelper.getAuthToken();
    final role = await PreferencesHelper.getUserRole();
    
    if (token != null && role != null) {
      // Jika token ada, return token (simulasi berhasil login via biometrik)
      return role;
    }
    // Jika tidak ada token, user harus login manual terlebih dahulu
    return null;
  }
}