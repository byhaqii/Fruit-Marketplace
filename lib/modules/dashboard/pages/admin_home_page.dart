// lib/modules/dashboard/pages/admin_home_page.dart

import 'dart:async'; // 1. Tambahkan import ini untuk Timer
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../providers/dashboard_provider.dart';
import '../../../../providers/notification_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../Data/pages/user_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  Timer? _timer; // 2. Variabel Timer

  @override
  void initState() {
    super.initState();
    
    // Load pertama kali saat buka
    _fetchData();

    // 3. Mulai Auto Refresh setiap 10 detik
    _startAutoRefresh();
  }

  @override
  void dispose() {
    // 4. PENTING: Matikan timer saat keluar halaman agar tidak memakan memori
    _timer?.cancel();
    super.dispose();
  }

  // Fungsi helper untuk mengambil data
  void _fetchData() {
    // Gunakan listen: false karena ini di dalam fungsi, bukan build
    Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
    Provider.of<NotificationProvider>(context, listen: false).fetchActivities();
  }

  void _startAutoRefresh() {
    // Timer berjalan setiap 10 detik
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchData();
      // Opsional: Print log untuk memastikan berjalan
      // print("Auto-refreshing data..."); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Gunakan Consumer atau ambil provider state untuk UI
    // Perhatikan: Kita tidak menggunakan 'isLoading' global untuk loading
    // agar saat auto-refresh, layar tidak berkedip/muncul loading spinner terus.
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    
    final user = authProvider.user;

    const Color primaryGreen = Color(0xFF2D7F6A);
    const Color darkText = Color(0xFF1E5A4A);

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
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    image: const DecorationImage(
                      image: AssetImage('assets/image-1.png'),
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
            // Hapus loading spinner fullscreen agar refresh terasa seamless
            // child: dashboardProvider.isLoading ? ... 
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. STATS CARDS (Data Real-time)
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