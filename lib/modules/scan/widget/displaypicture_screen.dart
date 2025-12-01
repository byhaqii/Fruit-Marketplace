// lib/modules/scan/widget/displaypicture_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
// Import target page
import '../../marketplace/pages/produk_list_page.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String? ocrResult; 
  final String? searchQuery; 

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    this.ocrResult, 
    this.searchQuery, 
  });

  @override
  Widget build(BuildContext context) {
    // Warna utama aplikasi
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

            // Tampilkan Hasil Klasifikasi (Jenis dan Confidence)
            ListTile(
              leading: const Icon(Icons.info_outline, color: primaryColor),
              title: const Text('Jenis Buah Terklasifikasi'),
              subtitle: Text(ocrResult ?? 'Klasifikasi gagal.'),
            ),
            
            // Tampilkan Hasil Pencarian/Rekomendasi
            ListTile(
              leading: const Icon(Icons.search, color: primaryColor),
              title: const Text('Rekomendasi Pencarian'),
              subtitle: Text(searchQuery ?? 'Tidak ada rekomendasi.'),
            ),
            
            // Tombol Lanjut ke Halaman Produk
            if (searchQuery != null && searchQuery!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // IMPLEMENTASI NAVIGASI: Pindah ke ProdukListPage dan bawa query
                    Navigator.of(context).pushAndRemoveUntil( // Gunakan pushAndRemoveUntil untuk kembali ke root flow
                      MaterialPageRoute(
                        builder: (context) => ProdukListPage(
                          initialSearchQuery: searchQuery, // Kirim query
                        ),
                      ),
                      (Route<dynamic> route) => route.isFirst, // Bersihkan semua route di atas root
                    );
                    
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