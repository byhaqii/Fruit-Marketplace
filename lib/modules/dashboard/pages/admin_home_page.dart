// lib/modules/dashboard/pages/admin_home_page.dart

import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../providers/dashboard_provider.dart';
import '../../../../providers/notification_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../Data/pages/user_page.dart';
import '../../../config/env.dart'; // <<< TAMBAHKAN INI

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  Timer? _timer; 

  @override
  void initState() {
    super.initState();
    
    _fetchData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- Helper URL Baru ---
  String _getStorageBaseUrl() {
    // Mengambil base URL dari Env dan menghapus '/api'
    return Env.apiBaseUrl.replaceFirst('/api', '');
  }

  String getAvatarUrl(String? filename) {
    if (filename == null || filename.isEmpty) return ''; 
    // Path storage sesuai konfigurasi backend: public/storage/profiles/
    return '${_getStorageBaseUrl()}/storage/profiles/$filename';
  }



  void _fetchData() {
    Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
    Provider.of<NotificationProvider>(context, listen: false).fetchActivities();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    
    final user = authProvider.user;

    const Color primaryGreen = Color(0xFF2D7F6A);
    const Color darkText = Color(0xFF1E5A4A);
    
    // LOGIC BARU UNTUK AVATAR
    final String? avatarFilename = user?.avatar;
    final bool hasAvatar = avatarFilename != null && avatarFilename.isNotEmpty;
    
    // Tentukan ImageProvider: NetworkImage jika ada avatar, AssetImage jika tidak
    final ImageProvider imageProvider = hasAvatar 
        ? NetworkImage(getAvatarUrl(avatarFilename!)) as ImageProvider
        : const AssetImage('assets/image-1.png') as ImageProvider;


    return Scaffold(
      backgroundColor: primaryGreen,
      body: Stack(
        children: [
          // --- HEADER ---
          Positioned(
            top: 60,
            left: 25,
            right: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user?.name ?? "Admin"}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                // FIX: Ubah Container Avatar
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    image: DecorationImage(
                      image: imageProvider, // Gunakan imageProvider
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ],
            ),
          ),

          // --- CONTENT SHEET ---
          Container(
            margin: const EdgeInsets.only(top: 160),
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. STATS CARDS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(
                        context,
                        title: 'Total Users',
                        value: '${dashboardProvider.totalUsers}',
                        icon: Icons.people_alt_outlined,
                        color: primaryGreen,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListPage()));
                        },
                      ),
                      _buildStatCard(
                        context,
                        title: 'New Users',
                        value: '+ ${dashboardProvider.newUsers}',
                        icon: Icons.person_add_alt_1_outlined,
                        color: primaryGreen,
                      ),
                      _buildStatCard(
                        context,
                        title: 'Active Users',
                        value: '${dashboardProvider.activeUsers}',
                        icon: Icons.online_prediction,
                        color: primaryGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 2. CHART SECTION
                  const Text(
                    'Log Activity',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _generateChartPoints(dashboardProvider.chartData),
                            isCurved: true,
                            color: const Color(0xFF8979FF),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF8979FF).withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. ACTIVITY LOG LIST (Auto Refresh)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      // Indikator visual kecil jika sedang refresh (Opsional)
                      if (dashboardProvider.isLoading)
                        const SizedBox(
                          width: 15, height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2, color: primaryGreen),
                        )
                    ],
                  ),
                  const SizedBox(height: 10),

                  Consumer<NotificationProvider>(
                    builder: (context, notifProvider, child) {
                      final logs = notifProvider.activityLogs;

                      if (logs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: Text("Belum ada aktivitas tercatat")),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          IconData icon = Icons.notifications_none;
                          Color iconColor = Colors.blue;
                          if (log.type == 'order') {
                            icon = Icons.shopping_cart;
                            iconColor = primaryGreen;
                          } else if (log.type == 'alert') {
                            icon = Icons.warning_amber;
                            iconColor = Colors.orange;
                          }

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: iconColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: iconColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontFamily: 'Poppins', 
                                            fontSize: 13, 
                                            color: Colors.black87
                                          ),
                                          children: [
                                            TextSpan(
                                              text: log.userName != null ? "${log.userName} " : "Sistem ",
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(text: log.body),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        log.date,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // 4. CURRENT BALANCE
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Current Balance", style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dashboardProvider.formattedBalance,
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                              child: const Text("▲ +2.4%", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.26,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateChartPoints(List<double> data) {
    return data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
  }
}