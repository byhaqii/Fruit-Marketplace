// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Tambahkan provider lain di sini (Keuangan, Warga, dll.)
      ],
      child: const App(), // App akan me-render AuthCheck di dalamnya
    ),
  );
}