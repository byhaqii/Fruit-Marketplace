// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// 1. IMPORT SEMUA PROVIDER
import 'providers/notification_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/keuangan_provider.dart';
import 'providers/warga_provider.dart';
import 'providers/dashboard_provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        // 2. DAFTARKAN SEMUA PROVIDER DI SINI
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => KeuanganProvider()),
        ChangeNotifierProvider(create: (_) => WargaProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()), 
      ],
      child: const App(), 
    ),
  );
}