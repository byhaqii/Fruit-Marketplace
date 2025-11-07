// lib/modules/auth/pages/login_page.dart
import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
              // Hapus BoxDecoration image, kita pindahkan ke Stack
              child: Stack( 
                children: [
                  // Layer 0: Gambar Latar Belakang Penuh (Background Asli)
                  const Positioned.fill(
                    child: Image(
                      image: AssetImage('assets/fruit_background.jpg'), 
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Layer 1: Gradasi Hijau Transparan (Overlay)
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
                            // Mulai dari 50% opacity, agar gambar terlihat
                            primaryColor.withOpacity(0.5), 
                            // Memudar ke 10% opacity, transisi yang lebih halus
                            primaryColor.withOpacity(0.1), 
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Layer 2: Teks "Hallo!"
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, left: 30),
                    child: Align(
                      alignment: const Alignment(-0.8, 0.5), // Posisikan di tengah-tengah area teks
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text( 
                            'Hallo!',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, 
                            ),
                          ),
                          Text(
                            'Welcome to Fruit Market', 
                            style: TextStyle(
                              fontSize: 16,
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
              // Geser ke atas agar kurva tumpang tindih dengan header
              transform: Matrix4.translationValues(0.0, -40.0, 0.0), 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 20),
                    const LoginForm(),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register'); 
                        },
                        child: Text('Don\'t have account? Sign Up', 
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