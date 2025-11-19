import 'package:flutter/material.dart';
import '../models/keuangan_model.dart'; // <-- 1. Import model
import '../core/network/api_client.dart'; // <-- 2. Import ApiClient

class KeuanganProvider with ChangeNotifier {
  final ApiClient apiClient;

  // --- STATE ---
  bool _isLoading = false;
  String _formattedBalance = "Rp 0,-"; // Default balance
  List<KeuanganModel> _expenses = [];

  // --- GETTERS (Untuk dibaca oleh UI) ---
  bool get isLoading => _isLoading;
  String get formattedBalance => _formattedBalance;
  List<KeuanganModel> get expenses => _expenses;

  // --- CONSTRUCTOR ---
  KeuanganProvider({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient() {
    // Panggil fungsi untuk mengambil data saat provider pertama kali dibuat
    fetchKeuanganData();
  }

  // --- DATA FETCHING ---
  Future<void> fetchKeuanganData() async {
    _isLoading = true;
    notifyListeners();

    // --- DI APLIKASI NYATA ---
    // Di sinilah Anda akan memanggil API client Anda
    // try {
    //   // 1. Ambil Saldo
    //   final balanceData = await apiClient.get('/keuangan/balance');
    //   // Asumsi API mengembalikan: {"balance": 3589000, "formatted": "Rp. 3.589.000,-"}
    //   _formattedBalance = balanceData['formatted'] ?? "Rp 0,-";
    //
    //   // 2. Ambil Daftar Pengeluaran
    //   final expensesData = await apiClient.get('/keuangan/expenses'); // Ini adalah List
    //
    //   // Cek jika data adalah list sebelum di-map
    //   if (expensesData is List) {
    //     _expenses = expensesData
    //         .map((json) => KeuanganModel.fromJson(json as Map<String, dynamic>))
    //         .toList();
    //   } else {
    //     _expenses = [];
    //   }
    //
    // } catch (e) {
    //   print('Error fetching keuangan data: $e');
    //   _formattedBalance = "Rp 0,-";
    //   _expenses = [];
    // }
    // -------------------------

    // Karena kita sudah menghapus data dummy dan belum terhubung ke API,
    // kita akan atur sebagai list kosong.
    _formattedBalance = "Rp 0,-"; // Default saat tidak ada data
    _expenses = []; // Default saat tidak ada data

    _isLoading = false;
    notifyListeners(); // Beri tahu UI bahwa loading selesai
  }
}