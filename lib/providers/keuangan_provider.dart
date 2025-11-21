// lib/providers/keuangan_provider.dart

import 'package:flutter/material.dart';
import '../models/keuangan_model.dart';
import '../core/network/api_client.dart';

class KeuanganProvider with ChangeNotifier {
  final ApiClient apiClient;

  // --- STATE ---
  bool _isLoading = false;
  String _formattedBalance = "Rp 0,-"; 
  List<KeuanganModel> _expenses = [];

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String get formattedBalance => _formattedBalance;
  List<KeuanganModel> get expenses => _expenses;

  // --- CONSTRUCTOR ---
  KeuanganProvider({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient() {
    fetchKeuanganData();
  }

  // --- DATA FETCHING ---
  Future<void> fetchKeuanganData() async {
    _isLoading = true;
    notifyListeners();

    // Simulasi Delay Network
    await Future.delayed(const Duration(seconds: 1));

    try {
      // --- DATA DUMMY (Ganti dengan API call nanti) ---
      _formattedBalance = "Rp 3.589.000,-";
      
      _expenses = [
        const KeuanganModel(
          id: 1,
          title: "Beli Pupuk Organik",
          transactions: "Toko Tani Jaya",
          amount: "-Rp 150.000",
          imageAsset: "assets/icons/shopping-bag.png", // Pastikan aset ini ada/ganti Icon
        ),
        const KeuanganModel(
          id: 2,
          title: "Top Up E-Wallet",
          transactions: "Transfer Bank BCA",
          amount: "+Rp 500.000",
          imageAsset: "assets/icons/wallet.png",
        ),
        const KeuanganModel(
          id: 3,
          title: "Bayar Listrik",
          transactions: "Token Listrik",
          amount: "-Rp 200.000",
          imageAsset: "assets/icons/bill.png",
        ),
      ];

    } catch (e) {
      debugPrint('Error fetching keuangan: $e');
      _formattedBalance = "Rp 0,-";
      _expenses = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}