// lib/modules/auth/pages/login_page.dart (Versi diperbaiki)

import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      // Latar belakang putih untuk keseluruhan Scaffold
      backgroundColor: Colors.white, 
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
           Container(
              height: size.height * 0.40, 
              width: size.width,
              // HAPUS BARIS INI:
              // color: Theme.of(context).colorScheme.primary.withOpacity(0.8), // <--- JANGAN GUNAKAN INI JIKA ADA DECORATION
              
              // Jaga agar Decoration menjadi satu-satunya sumber pewarnaan/styling
              decoration: BoxDecoration(
                // PINDAHKAN WARNA KE SINI:
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                
                // Coba muat gambar lagi (pastikan aset ada dan pubspec sudah di-get)
                image: const DecorationImage(
                  // GANTI DENGAN ASSET YANG BENAR
                 image: const AssetImage('assets/fruit_background.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black, BlendMode.dstATop // Gunakan dstATop agar warna tema Anda terlihat
                  ),
                ),
              ),
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 30, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Teks ini harus berwarna putih agar kontras dengan latar belakang ungu/hijau
                    const Text( 
                      'Hallo!',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, 
                      ),
                    ),
                    const Text(
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

            // Area Form dengan Curved Top (Tinggi 60%)
            Container(
              width: size.width,
              constraints: BoxConstraints(minHeight: size.height * 0.60),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), 
                  topRight: Radius.circular(40),
                ),
              ),
              // Geser ke atas untuk menutupi bagian bawah header
              transform: Matrix4.translationValues(0.0, -30.0, 0.0), 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const LoginForm(),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implementasi navigasi ke halaman Register
                        },
                        child: Text('Don\'t have account? Sign Up', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
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