// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/storage/preferences_helper.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient apiClient;
  bool _loading = false;
  
  // Tambahkan status baru
  bool _isLoggedIn = false;
  String? _userRole;

  bool get loading => _loading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole;

  AuthProvider({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();
  
  // Fungsi baru untuk mengecek status saat aplikasi dimulai
  Future<void> checkAuthStatus() async {
    final token = await PreferencesHelper.getAuthToken();
    final role = await PreferencesHelper.getUserRole();
    
    // Asumsi: jika ada token dan role, pengguna dianggap login
    if (token != null && role != null) {
      // Cek validitas token ke backend (Opsional, tapi disarankan)
      // Jika token valid, set state. Jika tidak, bersihkan token.
      
      // Untuk tujuan demo, kita asumsikan token yang ada valid
      _isLoggedIn = true;
      _userRole = role;
    } else {
      _isLoggedIn = false;
      _userRole = null;
    }
    notifyListeners();
  }


  Future<void> login(String email, String password) async {
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
          
          // Perbarui status Auth Provider setelah login berhasil
          _isLoggedIn = true;
          _userRole = role.toString();

          _setLoading(false);
          return; // Login berhasil
        }
      }
      throw Exception('Login gagal: Respon API tidak valid.');

    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> logout() async {
    // Panggil endpoint logout di backend (Protected Route)
    try {
      await apiClient.post('/auth/logout', null);
    } catch (e) {
      // Biarkan error, fokus pada penghapusan token lokal
    }
    await PreferencesHelper.clearAll();
    
    // Perbarui status Auth Provider setelah logout
    _isLoggedIn = false;
    _userRole = null;

    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}