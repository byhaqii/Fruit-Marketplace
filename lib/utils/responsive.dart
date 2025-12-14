import 'package:flutter/material.dart';

/// Returns a scale factor based on device width.
double responsiveScale(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w >= 1200) return 1.25; // desktop
  if (w >= 900) return 1.15; // large tablet
  if (w >= 600) return 1.05; // tablet
  return 1.0; // phone
}

/// Scale numeric values for padding, radius, spacing.
double rs(BuildContext context, double value) {
  return value * responsiveScale(context);
}

/// Scale font sizes mildly with clamping.
double rf(BuildContext context, double fontSize) {
  final scale = responsiveScale(context);
  final scaled = fontSize * (0.85 + (scale - 1.0) * 0.6);
  // Clamp to avoid oversized text on desktop
  return scaled.clamp(fontSize * 0.9, fontSize * 1.3);
}
