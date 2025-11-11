// lib/app.dart
import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'modules/auth/auth_check.dart'; // Import AuthCheck

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruitify ',
      theme: AppTheme.light(),
      // Gunakan AuthCheck sebagai home, atau sebagai initialRoute (kita gunakan route map)
      initialRoute: Routes.initial,
      routes: Routes.routes,

      debugShowCheckedModeBanner: false,
      
      // Fallback jika rute tidak ditemukan:
      onUnknownRoute: (settings) => MaterialPageRoute(builder: (context) => const AuthCheck()),
    );
  }
}