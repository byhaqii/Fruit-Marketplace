// lib/widgets/custom_textfield.dart

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  // --- TAMBAHKAN PARAMETER BERIKUT ---
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  // ------------------------------------

  const CustomTextField({
    super.key, 
    required this.hint,
    // --- INISIALISASI DI CONSTRUCTOR ---
    this.controller,
    this.validator,
    this.isPassword = false, // Beri nilai default
    // ------------------------------------
  });

  @override
  Widget build(BuildContext context) {
    // Ubah dari TextField menjadi TextFormField
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword, // Gunakan properti isPassword
      decoration: InputDecoration(
        hintText: hint,
        // Tambahkan border agar lebih jelas
        border: const OutlineInputBorder(), 
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
    );
  }
}