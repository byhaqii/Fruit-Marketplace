// lib/providers/notification_provider.dart

import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final ApiClient apiClient;

  // --- STATE ---
  List<NotificationModel> _notifications =
      []; // Notifikasi Pribadi (Sisi Buyer/Seller)
  List<NotificationModel> _activityLogs = []; // Activity Log (Sisi Admin)
  bool _isLoading = false;

  // --- GETTERS ---
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get activityLogs => _activityLogs;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient();

  // 1. FETCH NOTIFIKASI PRIBADI
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiClient.get('/notifications');
      if (response is List) {
        _notifications = response
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. FETCH ACTIVITY LOG (Khusus Admin)
  Future<void> fetchActivities() async {
    // Tidak menggunakan _isLoading global agar tidak mengganggu UI utama
    try {
      // Memanggil endpoint khusus Admin
      final response = await apiClient.get('/admin/activities');

      if (response is List) {
        _activityLogs = response
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        notifyListeners(); // Update UI Activity Log
      }
    } catch (e) {
      print("Error fetching activity logs: $e");
    }
  }

  // 3. TANDAI SEMUA DIBACA
  Future<void> markAllAsRead() async {
    try {
      await apiClient.post('/notifications/read-all', {});
      // Update state lokal menggunakan copyWith (yang sudah diperbaiki)
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Gagal menandai baca: $e");
    }
  }
}
