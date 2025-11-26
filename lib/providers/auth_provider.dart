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
      notifyListeners();

      // --- BAGIAN PENTING: AMBIL DATA USER TERBARU ---
      try {
        final response = await apiClient.get('/profile');
        
        if (response != null) {
          _user = UserModel.fromJson(response);
        }
      } catch (e) {
        print("Gagal mengambil profil user: $e");
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
        final token = resp['api_token'];

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

  // =======================================================
  //                 METODE UPDATE PROFILE (Disederhanakan)
  // =======================================================
  Future<void> updateProfile({
    required String name,
    required String email,
    // Parameter gender dan dob dihapus
    String? alamat,
    String? mobileNumber,
    String? password,
    String? avatarPath, 
  }) async {
    _setLoading(true);
    
    // Siapkan data untuk dikirim ke backend
    Map<String, dynamic> fields = {
      'name': name,
      'email': email,
      'alamat': alamat ?? '',
      'mobile_number': mobileNumber ?? '', // Pastikan key ini sesuai dengan validasi backend
      // Data gender dan dob dihapus
    };

    if (password != null && password.isNotEmpty) {
      fields['password'] = password;
    }
    
    const String path = '/profile'; 

    try {
      final response = await apiClient.postMultipart(
        path, 
        fields,
        fileFieldName: 'avatar', 
        filePath: avatarPath,
      );

      // Sinkronisasi data user dari respons backend
      if (response != null && response['user'] is Map<String, dynamic>) {
        final updatedUser = UserModel.fromJson(response['user']);
        _user = updatedUser; 
      } else {
         throw Exception("Respons update profil tidak valid.");
      }
      
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners(); 
    }
  }
  // =======================================================

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