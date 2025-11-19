import 'package:flutter/material.dart';
import '../models/user_model.dart'; // <-- 1. GANTI/GUNAKAN UserModel
import '../core/network/api_client.dart'; // <-- 2. IMPORT ApiClient

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
    // Panggil data saat provider pertama kali dibuat
    fetchWarga();
  }

  // --- METHODS ---
  Future<void> fetchWarga() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Asumsi endpoint API Anda adalah '/warga' atau '/users'
      final resp = await apiClient.get('/warga'); 

      if (resp is List) {
        // Ubah data JSON (List<Map>) menjadi List<UserModel>
        _wargaList = resp
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _wargaList = [];
      }
    } catch (e) {
      print('Error fetching warga: $e');
      _wargaList = []; // Set list kosong jika terjadi error
    }

    _isLoading = false;
    notifyListeners(); // Beri tahu UI bahwa data sudah siap
  }
  
  // TODO: Tambahkan fungsi deleteWarga() dan updateWarga() di sini
}