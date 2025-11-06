// lib/modules/auth/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/validator.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/loading_indicator.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submitLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );
        
        // Navigasi ke Dashboard setelah berhasil
        // Karena login, kita ingin mengganti stack rute agar user tidak bisa 'back' ke halaman login.
        Navigator.pushReplacementNamed(context, '/');

      } catch (e) {
        // Tampilkan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              hint: 'Email',
              controller: _emailController,
              validator: Validator.notEmpty,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: 'Password',
              controller: _passwordController,
              validator: Validator.notEmpty,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                if (auth.loading) {
                  return const LoadingIndicator();
                }
                return CustomButton(
                  label: 'Login',
                  onPressed: _submitLogin,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}