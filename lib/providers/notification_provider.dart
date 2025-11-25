import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final ApiClient apiClient;

  // --- STATE ---
  List<NotificationModel> _notifications = []; // Notifikasi Pribadi
  List<NotificationModel> _activityLogs = [];  // Activity Log (Admin)
  bool _isLoading = false;

  // --- GETTERS ---
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get activityLogs => _activityLogs;
  bool get isLoading => _isLoading;

  // Constructor
  NotificationProvider({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  // 1. FETCH NOTIFIKASI PRIBADI (User Biasa/Penjual)
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
    // Jangan set loading true global agar tidak mereset UI notifikasi lain jika ada
    try {
      // Pastikan endpoint ini sudah dibuat di Backend (NotificationController)
      final response = await apiClient.get('/admin/activities');
      
      if (response is List) {
        _activityLogs = response
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        notifyListeners(); // Update UI Log Activity
      }
    } catch (e) {
      print("Error fetching activity logs: $e");
    }
  }

  // 3. TANDAI SEMUA DIBACA
  Future<void> markAllAsRead() async {
    try {
      await apiClient.post('/notifications/read-all', {});
      // Update state lokal
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      print("Gagal menandai baca: $e");
    }
  }

  // 4. TANDAI SATU DIBACA (Opsional)
  void markAsRead(String id) {
    // Implementasi jika ada endpoint spesifik per ID
    // Saat ini update lokal saja
    final index = _notifications.indexWhere((n) => n.id.toString() == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }
}