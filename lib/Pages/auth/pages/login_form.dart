// lib/modules/auth/widgets/login_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Ganti SEMUA impor relatif yang rusak dengan impor package: yang stabil
import 'package:pbl_semester5/providers/auth_provider.dart';
import 'package:pbl_semester5/widgets/custom_textfield.dart';
import 'package:pbl_semester5/widgets/custom_button.dart';
import 'package:pbl_semester5/utils/validator.dart';
import 'package:pbl_semester5/widgets/loading_indicator.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );
        // Navigasi ke dashboard setelah login sukses.
        Navigator.of(context).pushReplacementNamed('/');
      } catch (e) {
        // Tampilkan error ke pengguna
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Gagal: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Menggunakan CustomTextField dan Validator
              CustomTextField(
                hint: 'Email (e.g. admin@mail.com)',
                controller: _emailController,
                validator: Validator.notEmpty, // Memanggil Validator
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hint: 'Password (e.g. 123456)',
                controller: _passwordController,
                isPassword: true, // Asumsi properti ini ada di CustomTextField
                validator: Validator.notEmpty, // Memanggil Validator
              ),
              const SizedBox(height: 24),
              // Menampilkan LoadingIndicator atau CustomButton
              authProvider.loading
                  ? const LoadingIndicator() // Memanggil LoadingIndicator
                  : CustomButton( // Memanggil CustomButton
                      label: 'Login',
                      onPressed: _submit,
                    ),
            ],
          ),
        );
      },
    );
  }
}