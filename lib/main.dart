// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';

void main() {
  // PENTING: Panggil WidgetsFlutterBinding.ensureInitialized()
  // jika Anda akan menggunakan SharedPreferences/Plugin sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Tambahkan provider lain di sini (Keuangan, Warga, dll.)
      ],
      child: const AppInitializer(),
    ),
  );
}

// Widget pembungkus untuk memastikan Provider sudah terinstal
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}