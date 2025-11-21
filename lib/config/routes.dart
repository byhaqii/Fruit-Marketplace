// lib/config/routes.dart
import 'package:flutter/material.dart';
import '../modules/dashboard/dashboard_page.dart';
import '../modules/auth/pages/login_page.dart';
import '../modules/auth/pages/register_page.dart';
import '../modules/auth/auth_check.dart';
import '../modules/marketplace/pages/produk_list_page.dart';
import '../modules/notification/pages/notification_page.dart';
import '../modules/warga/pages/warga_list_page.dart';
import '../modules/keuangan/pages/laporan_page.dart';

class Routes {
  static const String initial = '/auth-check'; 
  
  static final Map<String, WidgetBuilder> routes = {
    // Auth Flow
    initial: (context) => const AuthCheck(), 
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    
    // Core Modules (Hanya diakses melalui BottomNav)
    '/': (context) => const DashboardPage(),
    '/warga': (context) => const WargaListPage(),
    '/laporan': (context) => const LaporanPage(),
    '/produk': (context) => const ProdukListPage(),
    '/notifications': (context) => const NotificationPage(),
  };
}