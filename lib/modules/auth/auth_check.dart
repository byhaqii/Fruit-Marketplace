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
  // Gunakan FutureBuilder untuk menunggu status otentikasi
  late Future<void> _initAuth;

  @override
  void initState() {
    super.initState();
    // Panggil status check saat widget pertama kali dibuat
    _initAuth = Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initAuth,
      builder: (context, snapshot) {
        // Tampilkan Loading jika masih menunggu Future
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: LoadingIndicator()));
        }

        // Setelah selesai, gunakan Consumer untuk mendengarkan perubahan status login
        return Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (auth.isLoggedIn) {
              return const DashboardPage();
            } else {
              // Jika tidak login, tampilkan Login Page
              return const LoginPage();
            }
          },
        );
      },
    );
  }
}