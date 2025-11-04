// lib/modules/auth/pages/login_page.dart

import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import '../widgets/biometric_button.dart'; // PATH BARU

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // Hapus const dari Column di sini
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ 
              const Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const LoginForm(),
              const SizedBox(height: 20),
              const BiometricButton(), // Sekarang dapat menggunakan const
            ],
          ),
        ),
      ),
    );
  }
}