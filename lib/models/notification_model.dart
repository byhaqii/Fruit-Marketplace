// lib/models/notification_model.dart

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String date; // Format string, misal "12:30 PM" atau "10 Jan"
  final String type; // 'order' atau 'info'
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.type = 'info',
    this.isRead = false,
  });

  // CopyWith untuk memudahkan update status isRead (karena properti final)
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? date,
    String? type,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}