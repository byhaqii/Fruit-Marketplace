// lib/modules/auth/widgets/register_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/validator.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/loading_indicator.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _submitRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implementasi registrasi ke backend Lumen
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        // Asumsi: Logic registrasi akan memanggil API /auth/register (belum dibuat)
        // Untuk sekarang, kita mock sukses dan kembali ke Login.
        await Future.delayed(const Duration(seconds: 1)); // Mock loading
        
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Registrasi Sukses! Silakan Login.')),
        );
        Navigator.pop(context); // Kembali ke halaman login

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registrasi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Email
          CustomTextField(
            hint: 'Email',
            controller: _emailController,
            validator: Validator.isEmail,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Input Password
          CustomTextField(
            hint: 'Password',
            controller: _passwordController,
            validator: Validator.notEmpty,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Input Confirm Password
          CustomTextField(
            hint: 'Confirm Password',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
            validator: (val) {
              if (val != _passwordController.text) {
                return 'Password tidak cocok';
              }
              return Validator.notEmpty(val);
            },
          ),
          const SizedBox(height: 16),

          // Input Phone
          CustomTextField(
            hint: 'Phone',
            controller: _phoneController,
            validator: Validator.notEmpty,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
          ),

          const SizedBox(height: 30),

          // Tombol Sign Up
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              if (auth.loading) {
                return const Center(child: LoadingIndicator());
              }
              return CustomButton(
                label: 'Sign Up',
                onPressed: _submitRegister,
              );
            },
          ),
        ],
      ),
    );
  }
}