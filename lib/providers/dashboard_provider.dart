// lib/providers/dashboard_provider.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/transaksi_model.dart';
import '../models/notification_model.dart'; // <--- Import ini

class DashboardProvider with ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  
  // Stats
  int _totalUsers = 0;
  int _newUsers = 0;
  int _activeUsers = 0;
  
  // Data
  double _currentBalance = 0;
  List<TransaksiModel> _recentTransactions = [];
  List<NotificationModel> _activityLogs = []; // <--- State untuk Activity Log
  
  // Chart
  List<double> _chartData = [0, 0, 0, 0, 0, 0]; 

  // Getters
  bool get isLoading => _isLoading;
  int get totalUsers => _totalUsers;
  int get newUsers => _newUsers;
  int get activeUsers => _activeUsers;
  double get currentBalance => _currentBalance;
  List<TransaksiModel> get recentTransactions => _recentTransactions;
  List<NotificationModel> get activityLogs => _activityLogs; // <--- Getter baru
  List<double> get chartData => _chartData;

  String get formattedBalance => NumberFormat.currency(
        locale: 'id_ID', 
        symbol: 'Rp ', 
        decimalDigits: 0
      ).format(_currentBalance);

  DashboardProvider({ApiClient? apiClient}) 
      : apiClient = apiClient ?? ApiClient();

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Users
      final userResp = await apiClient.get('/users');
      if (userResp is List) {
        _totalUsers = userResp.length;
        _newUsers = (_totalUsers * 0.15).ceil(); 
        _activeUsers = (_totalUsers * 0.6).ceil();
      }

      // 2. Fetch Transactions
      final transResp = await apiClient.get('/transaksi/all');
      if (transResp is List) {
        final transactions = transResp.map((e) => TransaksiModel.fromJson(e)).toList();
        _recentTransactions = transactions.take(5).toList();
        _currentBalance = transactions
            .where((t) => t.isSuccess)
            .fold(0, (sum, t) => sum + t.totalHarga);
        
        // Update chart data dummy based on balance
        _chartData = List.generate(6, (index) => _currentBalance * ((index + 5) / 10));
      }

      // 3. Fetch Activity Logs (New)
      final activityResp = await apiClient.get('/admin/activities');
      if (activityResp is List) {
        _activityLogs = activityResp
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }

    } catch (e) {
      print("Gagal memuat dashboard: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}