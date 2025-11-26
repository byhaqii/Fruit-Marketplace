// lib/modules/scan/widget/displaypicture_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String? ocrResult; // <<< DEFINISIKAN PARAMETER BARU
  final String? searchQuery; // <<< DEFINISIKAN PARAMETER BARU

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    this.ocrResult, // Tambahkan ke list initialization
    this.searchQuery, // Tambahkan ke list initialization
  });

  @override
  Widget build(BuildContext context) {
    // Warna utama aplikasi (Ambil dari konstanta Anda, jika ada)
    const Color primaryColor = Color(0xFF2D7F6A); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Scan'),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gambar yang diambil/dipilih
            Image.file(File(imagePath)), 
            
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Hasil Pemrosesan:', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),

            // Tampilkan Hasil OCR
            ListTile(
              leading: const Icon(Icons.text_fields, color: primaryColor),
              title: const Text('Teks Terdeteksi (OCR)'),
              subtitle: Text(ocrResult ?? 'Tidak terdeteksi.'),
            ),
            
            // Tampilkan Hasil Pencarian/Rekomendasi
            ListTile(
              leading: const Icon(Icons.search, color: primaryColor),
              title: const Text('Rekomendasi Pencarian'),
              subtitle: Text(searchQuery ?? 'Tidak ada rekomendasi.'),
            ),
            
            // Tombol Lanjut ke Halaman Produk
            if (searchQuery != null)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Arahkan ke ProdukListPage dengan query pencarian
                    Navigator.pop(context); // Kembali dari DisplayPictureScreen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mencari produk: $searchQuery'))
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text('Cari Produk Ini', style: TextStyle(color: Colors.white)),
                ),
              )
          ],
        ),
      ),
    );
  }
}