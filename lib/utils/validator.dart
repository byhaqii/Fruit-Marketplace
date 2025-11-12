// lib/utils/validator.dart
class Validator {
  static String? notEmpty(String? v) =>
      (v == null || v.isEmpty) ? 'Tidak boleh kosong' : null;
  
  static String? isEmail(String? v) {
      if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(v)) return 'Format email tidak valid';
      return null;
  }
}