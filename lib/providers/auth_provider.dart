import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/storage/preferences_helper.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient apiClient;
  bool _loading = false;
  bool get loading => _loading;

  AuthProvider({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final resp = await apiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });
      if (resp is Map<String, dynamic>) {
        final role = resp['role'] ?? resp['data']?['role'];
        final token =
            resp['token'] ?? resp['access_token'] ?? resp['data']?['token'];
        if (token != null) {
          await PreferencesHelper.saveAuthToken(token.toString());
        }
        if (role != null) {
          await PreferencesHelper.saveUserRole(role.toString());
          _setLoading(false);
          return;
        }
      }
      throw Exception('Login gagal');
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
