// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'app.dart';
import 'providers/auth_provider.dart'; // Import AuthProvider

void main() {
  runApp(
    MultiProvider( // Gunakan MultiProvider jika nanti ada provider lain
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Tambahkan provider lain di sini (misalnya DashboardProvider)
      ],
      child: const App(),
    ),
  );
}