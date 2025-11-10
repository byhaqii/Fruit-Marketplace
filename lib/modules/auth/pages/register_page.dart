// lib/modules/auth/pages/register_page.dart
import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../widgets/register_form.dart'; 

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  // DEFINISI WARNA GRADASI BARU (Sama seperti Login)
  static const Color topGradientColor = Color(0xFF2D7F6A); 
  static const Color bottomGradientColor = Color(0xFF51E5BF);

  void _backToLogin(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
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
              child: Stack( 
                children: [
                  // Layer 0: Gambar Latar Belakang
                  const Positioned.fill(
                    child: Image(
                      image: AssetImage('assets/fruit_background.jpg'), 
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Layer 1: Gradasi Hijau Kustom (Overlay)
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
                          colors: [
                            topGradientColor.withOpacity(0.7), 
                            bottomGradientColor.withOpacity(0.5), 
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Layer 2: Tombol Back & Teks "Sign Up"
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () => _backToLogin(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          label: const Text('Back to login', style: TextStyle(color: Colors.white)),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                        
                        Expanded(
                          child: Align(
                            alignment: const Alignment(-0.8, 0.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text( 
                                  'Sign Up',
                                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, 
                                  ),
                                ),
                                Text(
                                  'Join ${AppConstants.marketplaceName}',
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.white70, 
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(
                        'Sign Up',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 20),
                      const RegisterForm(),
                      
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Kembali ke Login Page
                          },
                          child: Text('Already have an account? Login', 
                              style: TextStyle(color: primaryColor)),
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