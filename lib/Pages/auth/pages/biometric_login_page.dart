// lib/modules/auth/widgets/biometric_button.dart
import 'package:flutter/material.dart';

class BiometricButton extends StatelessWidget {
  const BiometricButton({super.key}); // Dideklarasikan sebagai const

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () {}, child: const Text('Use Biometric'));
  }
}