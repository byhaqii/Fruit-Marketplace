import 'package:flutter/material.dart';
import '../modules/dashboard/dashboard_page.dart';
import '../modules/auth/pages/login_page.dart';

class Routes {
  static const String initial = '/';
  static final Map<String, WidgetBuilder> routes = {
    initial: (context) => const DashboardPage(),
    '/login': (context) => const LoginPage(),
  };
}
