// lib/modules/profile/pages/aboutus_page.dart

import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // Warna sesuai tema aplikasi Anda
  static const Color kPrimaryColor = Color(0xFF2D7F6A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          // HEADER (Tombol Back)
          SafeArea(
            child: Container(
              height: 180,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // CONTENT BODY (Slide up container)
          Container(
            margin: const EdgeInsets.only(top: 140),
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "About Us",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // LOGO ICON
                  Container(
                    height: 120,
                    width: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                         BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5)
                         )
                      ]
                    ),
                    child: const Icon(Icons.local_grocery_store, size: 60, color: Colors.orange),
                  ),
                  const SizedBox(height: 15),
                  
                  // NAMA APLIKASI
                  const Text(
                    "FRUITIFY",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24, 
                      fontWeight: FontWeight.w900, 
                      color: kPrimaryColor,
                      letterSpacing: 2
                    ),
                  ),
                  const Text("F R U I T  S T O R E", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  
                  const SizedBox(height: 30),
                  
                  // DESKRIPSI
                  const Text(
                    "Fruitify is a local fruit marketplace designed to connect people within the same village or neighborhood with the freshest fruits around them. Our mission is to make fruit shopping easier, faster, and more enjoyable for everyone.\n\n"
                    "With Fruitify, users can discover various fruits sold by local farmers and sellers simply by scanning the fruit using our smart recognition feature. No more guessing, searching manually, or wasting time—just scan, find, and buy instantly.\n\n"
                    "We aim to support local communities by helping small fruit sellers reach more customers, while also giving users a convenient way to access fresh, high-quality produce close to home.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey, 
                      height: 1.6, 
                      fontSize: 13
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // SLOGAN BAWAH
                  const Text(
                    "Fresh fruits. Local sellers. Smart shopping.\nThat's Fruitify.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.black87, 
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}