// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/storage/preferences_helper.dart';
import '../models/user_model.dart'; // <-- 1. IMPORT UserModel

class AuthProvider with ChangeNotifier {
  final ApiClient apiClient;
  bool _loading = false;
  bool _isLoggedIn = false;
  String? _userRole;
  UserModel? _user; // <-- 2. TAMBAHKAN properti user

  bool get loading => _loading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole;
  UserModel? get user => _user; // <-- 3. TAMBAHKAN getter untuk user

  AuthProvider({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<void> checkAuthStatus() async {
    final token = await PreferencesHelper.getAuthToken();
    final role = await PreferencesHelper.getUserRole();

    if (token != null && role != null) {
      _isLoggedIn = true;
      _userRole = role;

      // 4. COBA AMBIL DATA USER (jika token ada)
      try {
        // Penting: Asumsi Anda punya endpoint '/auth/me' untuk dapat data user
        final resp = await apiClient.get('/auth/me');
        if (resp is Map<String, dynamic>) {
          _user = UserModel.fromJson(resp); // Simpan data user
        } else {
          // Jika respons tidak valid, logout
          await logout();
        }
      } catch (e) {
        // Gagal mengambil data user (misal token expired)
        await logout(); // Paksa logout jika data user gagal diambil
      }
    } else {
      // Kondisi jika tidak ada token/role
      _isLoggedIn = false;
      _userRole = null;
      _user = null;
    }
    // Tidak perlu notifyListeners di sini, karena AuthCheck akan membaca status awal
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
        // 5. AMBIL DATA USER DARI RESPON LOGIN
        // (Asumsi respons login Anda menyertakan objek 'user')
        final userData = resp['user'];

        if (token != null && role != null && userData != null) {
          await PreferencesHelper.saveAuthToken(token.toString());
          await PreferencesHelper.saveUserRole(role.toString());

          _isLoggedIn = true;
          _userRole = role.toString();
          // 6. SIMPAN OBJEK USER
          _user = UserModel.fromJson(userData);

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

  Future<void> logout() async {
    try {
      // Mengandalkan logic di ApiClient untuk mengirim token
      await apiClient.post('/auth/logout', null);
    } catch (e) {
      // Ignore error, fokus pada penghapusan token lokal
    }
    await PreferencesHelper.clearAll();
    _isLoggedIn = false;
    _userRole = null;
    _user = null; // <-- 7. BERSIHKAN data user saat logout
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}