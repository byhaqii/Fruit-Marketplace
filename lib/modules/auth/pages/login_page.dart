// lib/modules/auth/pages/login_page.dart
import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              SizedBox(height: 80),
              Text(
                'Selamat Datang di PBL Semester5', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 40),
              LoginForm(),
              // TODO: Masukkan BiometricButton di sini
            ],
          ),
        ),
      ),
    );
  }
}