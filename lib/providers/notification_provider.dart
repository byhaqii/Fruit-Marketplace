// lib/providers/notification_provider.dart

import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  
  // State variable untuk menyimpan daftar notifikasi
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  // Getter
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // Constructor
  NotificationProvider() {
    fetchNotifications();
  }

  // 1. FETCH DATA (Simulasi Data Dummy)
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulasi delay network

    // Isi data dummy agar UI tidak kosong
    _notifications = [
      const NotificationModel(
        id: '1',
        title: 'Pesanan Masuk',
        body: 'Anda menerima pesanan baru #ORD-001 dari Budi.',
        date: 'Baru saja',
        type: 'order',
        isRead: false,
      ),
      const NotificationModel(
        id: '2',
        title: 'Stok Menipis',
        body: 'Stok "Apel Fuji" tersisa kurang dari 5 kg.',
        date: '10:30 AM',
        type: 'info',
        isRead: false,
      ),
      const NotificationModel(
        id: '3',
        title: 'Pembayaran Diterima',
        body: 'Saldo sebesar Rp 150.000 telah masuk ke dompet.',
        date: 'Kemarin',
        type: 'info',
        isRead: true,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // 2. FUNGSI TANDAI SEMUA DIBACA (MARK ALL AS READ)
  void markAllAsRead() {
    // Kita buat list baru dengan mengubah status isRead menjadi true semua
    _notifications = _notifications.map((notif) {
      return notif.copyWith(isRead: true);
    }).toList();
    
    notifyListeners(); // Update UI
  }

  // 3. FUNGSI TANDAI SATU DIBACA (Opsional, untuk onTap)
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }
}