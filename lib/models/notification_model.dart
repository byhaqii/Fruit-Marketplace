// lib/models/notification_model.dart

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String date;
  final String type; // 'order', 'info', 'alert'
  final bool isRead;
  final String? userName; // Tambahan untuk Activity Log (Nama Pelaku)

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.type = 'info',
    this.isRead = false,
    this.userName,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk memparsing user jika di-include dari backend (untuk Activity Log)
    String? extractedName;
    if (json['user'] != null && json['user']['name'] != null) {
      extractedName = json['user']['name'];
    }

    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? 'Notifikasi',
      body: json['body'] ?? '',
      // Ambil created_at dari backend
      date: json['created_at'] ?? '-', 
      type: json['type'] ?? 'info',
      // Handle boolean dari integer (0/1) atau boolean true/false
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      userName: extractedName,
    );
  }

  // --- PERBAIKAN: Tambahkan kembali method copyWith ---
  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    String? date,
    String? type,
    bool? isRead,
    String? userName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      userName: userName ?? this.userName,
    );
  }
}