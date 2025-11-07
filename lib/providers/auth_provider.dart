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