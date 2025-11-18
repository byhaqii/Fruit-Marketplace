// lib/modules/notifications/pages/notification_page.dart
import 'package:flutter/material.dart';
import '../../../../models/notification_model.dart'; // <-- PASTIKAN PATH INI SESUAI

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Warna hijau utama dari gambar
  static const Color primaryGreen = Color.fromARGB(255, 56, 142, 60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: NotificationModel.dummyNotifications.length,
        itemBuilder: (context, index) {
          final notification = NotificationModel.dummyNotifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final Color statusColor = notification.isSuccess ? primaryGreen : Colors.red;
    // Hapus statusBackgroundColor karena tidak diperlukan lagi
    // final Color statusBackgroundColor = notification.isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  // --- PERUBAHAN DI SINI ---
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Background transparan
                    borderRadius: BorderRadius.circular(8), // Radius border
                    border: Border.all( // Tambahkan border
                      color: statusColor, // Warna border sesuai status
                      width: 1.5, // Ketebalan border
                    ),
                  ),
                  // --- AKHIR PERUBAHAN ---
                  child: Text(
                    notification.isSuccess ? 'Berhasil' : 'Gagal',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Loop untuk menampilkan setiap item notifikasi
            ...notification.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.weight,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.price,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              '${notification.time}, ${notification.date}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}