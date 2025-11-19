// lib/models/notification_model.dart

class NotificationModel {
  final String title;
  final String time;
  final String date;
  final List<NotificationItem> items; // List untuk menangani multiple items
  final bool isSuccess; // true untuk 'Berhasil', false untuk 'Gagal'

  const NotificationModel({
    required this.title,
    required this.time,
    required this.date,
    required this.items,
    required this.isSuccess,
  });
}

class NotificationItem {
  final String name;
  final String weight;
  final String price;

  const NotificationItem({
    required this.name,
    required this.weight,
    required this.price,
  });
}