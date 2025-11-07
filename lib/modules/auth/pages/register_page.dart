// lib/modules/auth/pages/register_page.dart

import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  void _backToLogin(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // DEFINISI WARNA GRADASI BARU
    const Color topGradientColor = Color(0xFF26BE97); // Hijau Cerah/Teal
    const Color bottomGradientColor = Color(
      0xFF1E5A4A,
    ); // Hijau Gelap (Warna Tema)

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Area Header dengan Gambar dan Gradasi (40%)
            Container(
              height: size.height * 0.40,
              width: size.width,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                image: DecorationImage(
                  image: const AssetImage('assets/fruit_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Layer 1: Gradasi Hijau Kustom
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          // MENGGUNAKAN DUA WARNA BARU
                          colors: [
                            // Mulai dari 50% opacity, agar gambar terlihat
                            primaryColor.withOpacity(0.5),
                            // Memudar ke 10% opacity, transisi yang lebih halus
                            primaryColor.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Area Form dengan Curved Top
            Container(
              width: size.width,
              constraints: BoxConstraints(minHeight: size.height * 0.60),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              transform: Matrix4.translationValues(0.0, -40.0, 0.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Sign Up',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge!.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 20),
                    const RegisterForm(),

                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Kembali ke Login Page
                        },
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
