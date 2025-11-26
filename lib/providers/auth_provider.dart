import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // PENTING: Untuk update profile (Multipart/Form-data)
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

  // --- CHECK AUTH STATUS ---
  Future<void> checkAuthStatus() async {
    final token = await PreferencesHelper.getAuthToken();
    final role = await PreferencesHelper.getUserRole();

    if (token != null) {
      _isLoggedIn = true;
      _userRole = role;
      notifyListeners(); 

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
    } else {
      _isLoggedIn = false;
      _userRole = null;
      _user = null;
    }
    notifyListeners();
  }

  // --- LOGIN ---
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

  // --- LOGOUT ---
  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout', null);
    } catch (e) {
      // Abaikan error jaringan saat logout
    }

    await PreferencesHelper.clearAll();
    _isLoggedIn = false;
    _userRole = null;
    _user = null;
    notifyListeners();
  }
  
  // --- FUNGSI BARU: UPDATE PROFILE ---
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? alamat,
    String? mobileNumber,
    String? password,
    String? avatarPath, // Path lokal untuk upload file (opsional)
  }) async {
    _setLoading(true);
    try {
      Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'alamat': alamat,
        'mobile_number': mobileNumber,
      };

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      if (avatarPath != null) {
        // --- LOGIKA MULTIPART UNTUK FILE ---
        String fileName = avatarPath.split('/').last;
        FormData formData = FormData.fromMap({
          ...data,
          'avatar': await MultipartFile.fromFile(avatarPath, filename: fileName),
          // PENTING: Untuk PUT request yang membawa file, harus method spoofing
          '_method': 'PUT', 
        });

        // Kirim sebagai POST ke endpoint PUT /profile
        await apiClient.dio.post('/profile', data: formData, options: await apiClient.optionsWithAuth());
        
      } else {
        // Update standar (data JSON)
        await apiClient.put('/profile', data);
      }

      // Ambil data user terbaru dari backend untuk update UI
      await checkAuthStatus(); 
      _setLoading(false);
      return true;

    } on DioException catch (e) {
      _setLoading(false);
      // Lempar error agar bisa ditangkap oleh ProfilePage
      throw Exception(e.response?.data['message'] ?? 'Gagal update profil: Cek koneksi atau input.');
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }


  // --- LOADING HELPER ---
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}