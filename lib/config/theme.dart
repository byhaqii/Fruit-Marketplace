// lib/config/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Warna hijau primer dari mockup: #388E3C
  static const Color primaryGreen = Color(0xFF388E3C); 
  // Warna latar belakang form yang sangat terang
  static const Color lightBackground = Color(0xFFF7F7F7);

  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen, 
        primary: primaryGreen,
        secondary: primaryGreen, // Digunakan untuk link/text button
      ),
      scaffoldBackgroundColor: lightBackground, 
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge!.copyWith(
          color: primaryGreen, 
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}