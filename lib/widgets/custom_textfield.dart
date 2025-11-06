// lib/widgets/custom_textfield.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  // Tambahkan semua parameter yang dibutuhkan di LoginForm
  final TextEditingController? controller; 
  final String? Function(String?)? validator; 
  final TextInputType? keyboardType;
  final bool obscureText;
  
  const CustomTextField({
    super.key, 
    required this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false, // Default ke false
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField( // Ubah dari TextField ke TextFormField agar bisa menggunakan validator
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator, // Memungkinkan validasi form
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(), // Tampilan standar
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}