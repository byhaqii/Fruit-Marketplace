// lib/modules/dashboard/widgets/discount_card.dart
import 'package:flutter/material.dart';

class DiscountCard extends StatelessWidget {
  // Menambahkan callback function
  final VoidCallback? onPressed; 

  const DiscountCard({
    super.key, 
    this.onPressed, // Terima parameter di sini
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 166,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF9D423), // Kuning Emas
            Color(0xFFFF4E50), // Oranye Kemerahan
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dekorasi Lingkaran
          Positioned(
            top: -30, right: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -20, left: -20,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Konten Teks
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Promo Spesial",
                    style: TextStyle(
                      color: Color(0xFFFF4E50),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Diskon 30%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1, 1))]
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Untuk buah segar pilihan",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Tombol Beli (Sekarang Berfungsi!)
          Positioned(
            right: 20,
            bottom: 20,
            child: ElevatedButton(
              onPressed: onPressed, // <--- Panggil fungsi di sini
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF4E50),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                "Beli Sekarang",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Gambar Ilustrasi
          Positioned(
            right: 10, top: 15,
            child: Image.asset(
              'assets/fruit_basket.png',
              width: 100, height: 80, fit: BoxFit.contain,
              errorBuilder: (ctx, err, stack) => const Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }
}