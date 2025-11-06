// lib/modules/auth/auth_check.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../dashboard/dashboard_page.dart';
import 'pages/login_page.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  // Panggil status check saat widget dibuat
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
        Provider.of<AuthProvider>(context, listen: false).checkAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // Tampilkan Loading Indicator selama proses pengecekan status awal
        if (!auth.isLoggedIn && auth.userRole == null) {
          // Jika belum ada token dan role (status awal/logout), tampilkan Login Page
          return const LoginPage();
        } else if (auth.isLoggedIn) {
          // Jika sudah ada token dan role, langsung ke Dashboard
          return const DashboardPage();
        }
        
        // Pilihan fallback saat loading data inisialisasi
        return const Scaffold(
          body: Center(
            child: LoadingIndicator(),
          ),
        );
      },
    );
  }
}