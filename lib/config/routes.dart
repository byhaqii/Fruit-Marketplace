// lib/config/routes.dart
import 'package:flutter/material.dart';
import '../modules/dashboard/dashboard_page.dart';
import '../modules/auth/pages/login_page.dart';
import '../modules/auth/auth_check.dart'; // Import AuthCheck

class Routes {
  // Ubah initial menjadi rute pengecekan
  static const String initial = '/auth-check'; 
  
  static final Map<String, WidgetBuilder> routes = {
    // Rute pengecekan status, yang akan menjadi titik masuk aplikasi
    initial: (context) => const AuthCheck(), 
    
    // Rute utama aplikasi
    '/': (context) => const DashboardPage(),
    '/login': (context) => const LoginPage(),
    // TODO: Daftarkan rute modul lain di sini
  };
}