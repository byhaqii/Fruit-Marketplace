// lib/modules/auth/pages/login_page.dart
import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      // Scaffold background kini diatur oleh Theme
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Area Header (Mencapai 40% dari tinggi layar)
            Container(
              height: size.height * 0.40, 
              width: size.width,
              decoration: BoxDecoration(
                // Warna primer yang sudah diatur di theme
                color: Theme.of(context).colorScheme.primary, 
                image: const DecorationImage(
                  image: AssetImage('assets/fruit_background.jpg'), 
                  fit: BoxFit.cover,
                  // Gunakan filter yang lebih halus untuk kontras
                  colorFilter: ColorFilter.mode(
                    Colors.black, 
                    BlendMode.dstATop // Memungkinkan warna tema terlihat di atas gambar
                  ),
                ),
              ),
              // PENTING: Posisikan teks agak ke atas dan ke kiri
              alignment: const Alignment(-0.8, 0.5), // X: -0.8 (kiri), Y: 0.5 (agak ke atas)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text( 
                    'Hallo!',
                    style: TextStyle(
                      fontSize: 40, // Sedikit lebih kecil agar rapi
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

            // Area Form dengan Curved Top
            Container(
              width: size.width,
              constraints: BoxConstraints(minHeight: size.height * 0.60),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor, // Background Form mengikuti Scaffold
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40), 
                  topRight: Radius.circular(40),
                ),
              ),
              // Geser ke atas (sesuaikan nilai -30.0 jika kurang pas)
              transform: Matrix4.translationValues(0.0, -40.0, 0.0), 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Login (warna otomatis dari Theme Text Span)
                    Text(
                      'Login',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    const LoginForm(),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigasi ke Register
                        },
                        child: Text('Don\'t have account? Sign Up', 
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
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