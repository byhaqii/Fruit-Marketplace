// lib/modules/marketplace/widgets/produk_card.dart

import 'package:flutter/material.dart';
import '../../../models/produk_model.dart';
import '../../../config/theme.dart'; // Asumsi Anda punya file theme, jika tidak bisa dihapus

class ProdukCard extends StatelessWidget {
  final ProdukModel produk;
  final VoidCallback? onTap;

  const ProdukCard({
    super.key,
    required this.produk,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format harga ke Rupiah sederhana
    // Jika Anda punya helper formatter, bisa dipakai di sini
    final String hargaFormatted = "Rp ${produk.harga}"; 

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN GAMBAR ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(produk.imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Fallback jika gambar error/tidak ada
                    },
                  ),
                ),
                child: Stack(
                  children: [
                    // Badge Stok (Opsional)
                    if (produk.stok < 5)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Stok Menipis',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // --- BAGIAN TEXT DETAIL ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    produk.namaProduk,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Kategori (Opsional)
                  Text(
                    produk.kategori,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Harga & Tombol Add
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hargaFormatted,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E605A), // Warna Hijau Utama Anda
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E605A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}