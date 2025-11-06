// lib/config/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      // Menggunakan warna yang lebih hijau kebiruan seperti mockup Anda
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E8449), // Warna hijau gelap
        primary: const Color(0xFF1E8449), // Mengganti deepPurple default
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF0F0F0), // Latar belakang pudar
      // ... penyesuaian lain
    );
  }
}