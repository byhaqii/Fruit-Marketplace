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
        
        Navigator.pushReplacementNamed(context, '/'); 

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Email dengan Icon Email
          CustomTextField(
            hint: 'Email',
            controller: _emailController,
            validator: Validator.isEmail,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Input Password dengan Icon Lock
          CustomTextField(
            hint: 'Password',
            controller: _passwordController,
            validator: Validator.notEmpty,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          ),
          
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implementasi Forgot Password
              }, 
              child: Text('Forgot Password?', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              // Tombol Login
              Expanded(
                child: Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    if (auth.loading) {
                      return const Center(child: LoadingIndicator());
                    }
                    return CustomButton(
                      label: 'Login',
                      onPressed: _submitLogin,
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              // Tombol Biometrik (Face Recognition Icon)
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.face, size: 30),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    // TODO: Panggil Biometric Login
                  },
                ),
              )
            ],
          ),

        ],
      ),
    );
  }
}