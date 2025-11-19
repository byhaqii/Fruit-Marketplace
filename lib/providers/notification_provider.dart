import 'package:flutter/material.dart';
import '../models/notification_model.dart'; // <-- 1. Import model

class NotificationProvider with ChangeNotifier {
  
  // 2. State variable untuk menyimpan daftar notifikasi
  List<NotificationModel> _notifications = [];
  
  // 3. Getter (ini yang dipanggil oleh UI: `provider.notifications`)
  List<NotificationModel> get notifications => _notifications;

  // (Opsional tapi disarankan) Tambahkan state loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 4. Constructor: Panggil fungsi fetch saat provider pertama kali dibuat
  NotificationProvider() {
    fetchNotifications();
  }

  // 5. Fungsi untuk mengambil data (pengganti data dummy)
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners(); // Beri tahu UI bahwa kita sedang loading

    // --- DI APLIKASI NYATA ---
    // Di sinilah Anda akan memanggil API client Anda
    // try {
    //   final apiData = await apiClient.get('/notifications');
    //   // Ubah data JSON dari API menjadi List<NotificationModel>
    //   _notifications = apiData.map((json) => NotificationModel.fromJson(json)).toList();
    // } catch (e) {
    //   // Tangani error
    //   _notifications = [];
    // }
    // -------------------------

    // Karena kita sudah menghapus data dummy dan belum terhubung ke API,
    // kita akan atur sebagai list kosong.
    _notifications = [];

    _isLoading = false;
    notifyListeners(); // Beri tahu UI bahwa loading selesai
  }
}