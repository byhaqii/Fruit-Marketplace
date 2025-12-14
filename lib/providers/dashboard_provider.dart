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

  // Chart - User Growth
  String _growthPeriod = 'daily'; // 'daily', 'monthly', 'yearly'
  List<double> _chartData = [0, 0, 0, 0, 0, 0];
  List<String> _chartLabels = [];

  // Getters
  bool get isLoading => _isLoading;
  int get totalUsers => _totalUsers;
  int get newUsers => _newUsers;
  int get activeUsers => _activeUsers;
  double get currentBalance => _currentBalance;
  List<TransaksiModel> get recentTransactions => _recentTransactions;
  List<NotificationModel> get activityLogs => _activityLogs; // <--- Getter baru
  List<double> get chartData => _chartData;
  String get growthPeriod => _growthPeriod;
  List<String> get chartLabels => _chartLabels;

  String get formattedBalance => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(_currentBalance);

  DashboardProvider({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient();

  Future<void> setGrowthPeriod(String period) async {
    _growthPeriod = period;
    await loadUserGrowthChart();
  }

  Future<void> loadUserGrowthChart() async {
    try {
      final response = await apiClient.get(
        '/users/growth?period=$_growthPeriod',
      );
      if (response is Map<String, dynamic>) {
        final data = response['data'] as List;
        _chartData = data.map((e) => (e as num).toDouble()).toList();

        final labels = response['labels'] as List;
        _chartLabels = labels.map((e) => e.toString()).toList();
      }
      notifyListeners();
    } catch (e) {
      print("Gagal memuat user growth chart: $e");
    }
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch User Statistics (Real-time)
      final statsResp = await apiClient.get('/users/stats/dashboard');
      if (statsResp is Map<String, dynamic>) {
        _totalUsers = statsResp['total_users'] ?? 0;
        _newUsers = statsResp['new_users'] ?? 0;
        _activeUsers = statsResp['active_users'] ?? 0;
      }

      // 2. Fetch Transactions
      final transResp = await apiClient.get('/transaksi/all');
      if (transResp is List) {
        final transactions = transResp
            .map((e) => TransaksiModel.fromJson(e))
            .toList();
        _recentTransactions = transactions.take(5).toList();
        _currentBalance = transactions
            .where((t) => t.isSuccess)
            .fold(0, (sum, t) => sum + t.totalHarga);
      }

      // 3. Fetch Activity Logs (New)
      final activityResp = await apiClient.get('/admin/activities');
      if (activityResp is List) {
        _activityLogs = activityResp
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }

      // 4. Fetch User Growth Chart
      await loadUserGrowthChart();
    } catch (e) {
      print("Gagal memuat dashboard: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
