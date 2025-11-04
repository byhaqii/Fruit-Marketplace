import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
  }
}
