// lib/modules/auth/auth_check.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../dashboard/dashboard_page.dart';
import 'pages/biometric_login_page.dart'; // <-- Import Biometrik
import 'pages/login_page.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  
  late Future<void> _initAuthCheck;

  @override
  void initState() {
    super.initState();
    _initAuthCheck = Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initAuthCheck,
      builder: (context, snapshot) {
        // Tampilkan Splash Screen/Loading saat (checkAuthStatus) berjalan
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: LoadingIndicator(),
            ),
          );
        }

        // Setelah selesai, gunakan Consumer
        return Consumer<AuthProvider>(
          builder: (context, auth, child) {
            
            // 1. Jika sesi sudah aktif (baru saja login/biometrik)
            if (auth.isLoggedIn) { 
              return const DashboardPage();
            } 
            // 2. Jika token ada DAN biometrik diaktifkan
            else if (auth.isBiometricEnabled) {
              return const BiometricLoginPage();
            }
            // 3. Jika tidak ada token ATAU biometrik tidak aktif
            else {
              return const LoginPage();
            }
          },
        );
      },
    );
  }
}