// lib/providers/warga_provider.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/network/api_client.dart';

class WargaProvider with ChangeNotifier {
  final ApiClient apiClient;

  // --- STATE ---
  List<UserModel> _wargaList = [];
  bool _isLoading = false;

  // --- GETTERS ---
  List<UserModel> get wargaList => _wargaList;
  bool get isLoading => _isLoading;

  // --- CONSTRUCTOR ---
  WargaProvider({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient() {
    fetchWarga();
  }

  // 1. GET ALL USERS
  Future<void> fetchWarga() async {
    _isLoading = true;
    notifyListeners();

    try {
      final resp = await apiClient.get('/users'); 
      if (resp is List) {
        _wargaList = resp
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _wargaList = [];
      }
    } catch (e) {
      print('Error fetching users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. TAMBAH USER (ADD)
  Future<bool> addUser(Map<String, dynamic> data) async {
    try {
      // POST ke /users
      await apiClient.post('/users', data);
      
      // Refresh data setelah berhasil
      await fetchWarga(); 
      return true;
    } catch (e) {
      print("Gagal tambah user: $e");
      return false;
    }
  }

  // 3. EDIT USER (UPDATE)
  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    try {
      // PUT ke /users/{id}
      await apiClient.put('/users/$id', data);
      
      await fetchWarga();
      return true;
    } catch (e) {
      print("Gagal update user: $e");
      return false;
    }
  }

  // 4. HAPUS USER (DELETE)
  Future<bool> deleteUser(String id) async {
    try {
      await apiClient.delete('/users/$id');
      
      // Hapus dari list lokal biar UI responsif
      _wargaList.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print("Gagal hapus user: $e");
      return false;
    }
  }
}