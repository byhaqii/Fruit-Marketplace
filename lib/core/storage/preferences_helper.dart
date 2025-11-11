// lib/core/storage/preferences_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _kAuthToken = 'auth_token';
  static const String _kUserRole = 'user_role';
  static const String _kBiometricEnabled = 'biometric_enabled'; // <-- BARIS BARU

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAuthToken, token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAuthToken);
  }

  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserRole, role);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserRole);
  }

  // --- FUNGSI BARU UNTUK BIOMETRIK ---
  static Future<void> saveBiometricEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricEnabled, isEnabled);
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kBiometricEnabled) ?? false;
  }
  // --- AKHIR FUNGSI BARU ---


  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    // JANGAN HAPUS FLAG BIOMETRIK SAAT LOGOUT
    // await prefs.clear(); // <-- Ganti ini
    
    // Hapus hanya token dan role
    await prefs.remove(_kAuthToken);
    await prefs.remove(_kUserRole);
  }
}