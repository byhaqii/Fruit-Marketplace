// lib/modules/notification/pages/notification_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../models/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    // Ambil notifikasi saat halaman dibuka
    Future.microtask(() => 
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications()
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2D7F6A);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Tandai semua dibaca",
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Semua notifikasi ditandai sudah dibaca"))
              );
            },
          )
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Belum ada notifikasi baru", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            color: primaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = provider.notifications[index];
                return _buildNotificationItem(context, notif);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notif) {
    return Container(
      color: notif.isRead ? Colors.transparent : const Color(0xFFE0F2F1), // Hijau muda jika belum dibaca
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2D7F6A).withOpacity(0.1),
          child: Icon(
            notif.type == 'order' ? Icons.shopping_bag : Icons.info,
            color: const Color(0xFF2D7F6A),
          ),
        ),
        title: Text(
          notif.title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notif.body, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              notif.date, // Pastikan model punya field date/time
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
        onTap: () {
          // Tandai sudah dibaca
          // Provider.of<NotificationProvider>(context, listen: false).markAsRead(notif.id);
          
          // Navigasi jika perlu (misal ke detail pesanan)
        },
      ),
    );
  }
}