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

  // Dummy data untuk demonstrasi
  static List<NotificationModel> dummyNotifications = [
    NotificationModel(
      title: 'Pembelian Buah',
      time: '11:00',
      date: '13 Nov 2025',
      items: [
        NotificationItem(name: 'Banana Tionghoa', weight: '0,5 Kg (Pcs)', price: 'Rp. 35.000,-'),
      ],
      isSuccess: true,
    ),
    NotificationModel(
      title: 'Pembelian Buah',
      time: '11:00',
      date: '13 Nov 2025',
      items: [
        NotificationItem(name: 'Banana Tionghoa', weight: '0,5 Kg (Pcs)', price: 'Rp. 35.000,-'),
        NotificationItem(name: 'Pakistan Apple', weight: '0,5 Kg (Pcs)', price: 'Rp. 55.000,-'),
      ],
      isSuccess: false,
    ),
    NotificationModel(
      title: 'Pembelian Buah',
      time: '11:00',
      date: '13 Nov 2025',
      items: [
        NotificationItem(name: 'Banana Tionghoa', weight: '0,5 Kg (Pcs)', price: 'Rp. 35.000,-'),
      ],
      isSuccess: true,
    ),
    NotificationModel(
      title: 'Pembelian Buah',
      time: '11:00',
      date: '13 Nov 2025',
      items: [
        NotificationItem(name: 'Banana Tionghoa', weight: '0,5 Kg (Pcs)', price: 'Rp. 35.000,-'),
      ],
      isSuccess: true,
    ),
  ];
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