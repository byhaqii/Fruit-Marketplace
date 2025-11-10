// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/services/biometric_service.dart'; 
import '../core/storage/preferences_helper.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient apiClient;
  bool _loading = false;
  
  bool _isLoggedIn = false;
  bool _isBiometricEnabled = false; 
  String? _userRole;

  bool get loading => _loading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isBiometricEnabled => _isBiometricEnabled; 
  String? get userRole => _userRole;

  AuthProvider({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();
  
  
  Future<void> setAuthenticated(bool status) async {
    if (status) {
      _isLoggedIn = true;
      _userRole = await PreferencesHelper.getUserRole();
    } else {
      _isLoggedIn = false;
      _userRole = null;
    }
    notifyListeners();
  }

  // (Diubah) checkAuthStatus hanya mengecek flag, tidak auto-login
  Future<void> checkAuthStatus() async {
    final token = await PreferencesHelper.getAuthToken();
    final isBiometricOn = await PreferencesHelper.isBiometricEnabled();
    
    _isLoggedIn = false; // Selalu false saat app start
    _userRole = null;
    
    if (token != null && isBiometricOn) {
      _isBiometricEnabled = true; // Punya token DAN fitur aktif
    } else {
      _isBiometricEnabled = false; // Tidak punya token ATAU fitur tidak aktif
    }
    // notifyListeners() tidak diperlukan di sini, FutureBuilder akan menangani
  }


  Future<void> login(String email, String password) async {
    // ... (Fungsi login Anda tetap sama) ...
    _setLoading(true);
    try {
      final resp = await apiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (resp is Map<String, dynamic>) {
        final role = resp['role'];
        final token = resp['token'];

        if (token != null && role != null) {
          await PreferencesHelper.saveAuthToken(token.toString());
          await PreferencesHelper.saveUserRole(role.toString());
          
          _isLoggedIn = true;
          _userRole = role.toString();
          // (Kita tidak set _isBiometricEnabled di sini, itu diatur di Settings)

          _setLoading(false);
          return; 
        }
      }
      throw Exception('Login gagal: Respon API tidak valid.');

    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // --- FUNGSI BARU UNTUK MEREGISTRASI BIOMETRIK ---
  Future<bool> enableBiometrics() async {
    final biometricService = BiometricService();
    try {
      if (await biometricService.isBiometricAvailable()) {
        // Minta konfirmasi sidik jari
        final didAuth = await biometricService.authenticate(); 
        if (didAuth) {
          await PreferencesHelper.saveBiometricEnabled(true);
          _isBiometricEnabled = true;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // Gagal
    }
    return false;
  }
  
  Future<void> disableBiometrics() async {
    await PreferencesHelper.saveBiometricEnabled(false);
    _isBiometricEnabled = false;
    notifyListeners();
  }
  // --- AKHIR FUNGSI BARU ---


  Future<void> register(String name, String email, String password, String confirmPassword, String phone) async {
    _setLoading(true);
    try {
      final resp = await apiClient.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'phone': phone,
      });

      if (resp is Map<String, dynamic> && resp.containsKey('message')) {
         _setLoading(false);
         return;
      }
      
      throw Exception('Registrasi gagal: Respon API tidak valid.');

    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout', null);
    } catch (e) {
      // Abaikan error
    }
    // PreferencesHelper.clearAll() (yang sudah diubah) tidak menghapus flag biometrik
    await PreferencesHelper.clearAll(); 
    
    _isLoggedIn = false;
    _userRole = null;
    // _isBiometricEnabled tetap true (jika user sudah mengaktifkannya)
    
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}