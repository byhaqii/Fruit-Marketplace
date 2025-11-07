// lib/modules/marketplace/page/produk_detail_page.dart
import 'package:flutter/material.dart';
import '../../../models/produk_model.dart';

class ProdukDetailPage extends StatelessWidget {
  final ProdukModel produk;

  const ProdukDetailPage({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(produk.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: produk.id,
              child: AspectRatio(
                aspectRatio: 1.4,
                child: Image.network(
                  produk.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) =>
                      Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    produk.formattedPrice,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    produk.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Ditambahkan ke keranjang')));
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Tambah ke Keranjang'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
