// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/storage/preferences_helper.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient apiClient;
  bool _loading = false;
  bool _isLoggedIn = false;
  String? _userRole;

  bool get loading => _loading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole;

  AuthProvider({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();
  
  Future<void> checkAuthStatus() async {
    final token = await PreferencesHelper.getAuthToken();
    final role = await PreferencesHelper.getUserRole();
    
    if (token != null && role != null) {
      _isLoggedIn = true;
      _userRole = role;
    } else {
      _isLoggedIn = false;
      _userRole = null;
    }
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
          
          _isLoggedIn = true;
          _userRole = role.toString();

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
  
  // --- TAMBAHKAN FUNGSI BARU INI ---
  Future<void> register(String name, String email, String password, String confirmPassword, String phone) async {
    _setLoading(true);
    try {
      // Panggil API Register ke backend Lumen
      // ApiClient akan otomatis mengirim FormData karena path /auth/register
      final resp = await apiClient.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'phone': phone,
      });

      // Jika berhasil (201), backend akan mengembalikan pesan sukses
      if (resp is Map<String, dynamic> && resp.containsKey('message')) {
         _setLoading(false);
         return; // Sukses
      }
      
      throw Exception('Registrasi gagal: Respon API tidak valid.');

    } catch (e) {
      _setLoading(false);
      rethrow; // Biarkan UI (RegisterForm) menangani error
    }
  }
  // --- AKHIR FUNGSI BARU ---

  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout', null);
    } catch (e) {
      // Abaikan error, fokus pada penghapusan token lokal
    }
    await PreferencesHelper.clearAll();
    _isLoggedIn = false;
    _userRole = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}