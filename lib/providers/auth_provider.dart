// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/storage/preferences_helper.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient apiClient;
  bool _loading = false;
  bool _isLoggedIn = false;
  String? _userRole;
  UserModel? _user;

  bool get loading => _loading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole;
  UserModel? get user => _user;

  AuthProvider({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<void> checkAuthStatus() async {
    final token = await PreferencesHelper.getAuthToken();
    final role = await PreferencesHelper.getUserRole();

    if (token != null) {
      _isLoggedIn = true;
      _userRole = role;
      notifyListeners(); // Update UI sementara (status login true)

      // --- BAGIAN PENTING: AMBIL DATA USER TERBARU ---
      try {
        // Panggil endpoint '/profile' yang ada di web.php backend
        final response = await apiClient.get('/profile');
        
        if (response != null) {
          // Konversi JSON ke UserModel
          _user = UserModel.fromJson(response);
          
          // Update role jika backend mengirimnya, atau pakai yang tersimpan
          // _userRole = _user?.role ?? _userRole; 
        }
      } catch (e) {
        print("Gagal mengambil profil user: $e");
        // Jika error 401 (Unauthorized), berarti token kadaluarsa -> Logout
        if (e.toString().contains('401')) {
           await logout();
           return;
        }
      }
      // -----------------------------------------------
      
    } else {
      _isLoggedIn = false;
      _userRole = null;
      _user = null;
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
        final userData = resp['user'];
        final token = resp['api_token']; // Pastikan key sesuai backend

        // Ambil role dari dalam object user, default 'pembeli'
        String role = 'pembeli';
        if (userData != null && userData['role'] != null) {
          role = userData['role'].toString();
        }

        if (token != null && userData != null) {
          await PreferencesHelper.saveAuthToken(token.toString());
          await PreferencesHelper.saveUserRole(role);

          _isLoggedIn = true;
          _userRole = role;
          _user = UserModel.fromJson(userData);

          _setLoading(false);
          return;
        }
      }
      throw Exception('Login gagal: Token tidak ditemukan.');
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout', null);
    } catch (e) {
      // Ignore network error
    }
    await PreferencesHelper.clearAll();
    _isLoggedIn = false;
    _userRole = null;
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}