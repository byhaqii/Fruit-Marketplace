// lib/modules/marketplace/page/produk_detail_page.dart
import 'package:flutter/material.dart';
import '../../../models/produk_model.dart';

class ProdukDetailPage extends StatelessWidget {
  final ProdukModel produk;

  const ProdukDetailPage({super.key, required this.produk});

  // ... (Methods _buildProductInfo, _buildQuantityOption, _buildInfoSection, _buildReviewSection, _buildBottomActionButtons DITAMPILKAN DI BAWAH)

  @override
  Widget build(BuildContext context) {
    // Hapus deklarasi dummyDescription yang tidak terpakai

    return Scaffold(
      appBar: AppBar(
        title: Text(produk.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: produk.id,
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Container(
                      color: const Color(0xFFF9E8E8),
                      child: Image.network(
                        produk.imageUrl, // Menggunakan imageUrl dari model
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductInfo(context, produk),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Colors.black12),
                      const SizedBox(height: 16),
                      _buildInfoSection('Informasi Produk', produk.description), // Menggunakan deskripsi dari model
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Colors.black12),
                      const SizedBox(height: 16),
                      _buildReviewSection(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomActionButtons(context),
        ],
      ),
    );
  }

  // --- METHODS DARI PRODUK DETAIL PAGE ---
  Widget _buildProductInfo(BuildContext context, ProdukModel produk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          produk.title, // Menggunakan title dari model
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          produk.formattedPrice,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuantityOption(context, '500 g', true),
            const SizedBox(width: 8),
            _buildQuantityOption(context, '1 kg', false),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 20),
            const Spacer(),
            const Icon(Icons.favorite_border, color: Colors.black54),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildQuantityOption(BuildContext context, String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.green : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 14),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        const Text(
          'More ⌵',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('4.9', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Icon(Icons.star, color: Colors.amber[700], size: 20),
                const SizedBox(width: 4),
                const Text('Penilaian Produk (5.2RB)', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const Text('View All >', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(width: 80, height: 40, color: Colors.grey[200]),
            const SizedBox(width: 8),
            Container(width: 80, height: 40, color: Colors.grey[200]),
            const SizedBox(width: 8),
            Container(width: 80, height: 40, color: Colors.grey[200]),
          ],
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: const Text('Fahreiza Taura TI - 3I', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(Icons.star, color: Colors.amber[700], size: 16)]),
              const SizedBox(height: 4),
              const Text(
                'Buah ta kontol cak. Suah rasane koyok memek goblog ketepak nambu gcxkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk sanco kkkkkkkkkkkkkkkk...',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'More ⌵',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButtons(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // --- TOMBOL CHAT DIHAPUS ---
            // Expanded(
            //   flex: 1,
            //   child: OutlinedButton(
            //     onPressed: () {},
            //     style: OutlinedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(vertical: 14),
            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            //       side: BorderSide(color: Colors.grey[400]!),
            //     ),
            //     child: const Icon(Icons.chat_bubble_outline, color: Colors.black),
            //   ),
            // ),
            // const SizedBox(width: 10), // Spacer chat dihapus
            
            Expanded(
              flex: 3, // Flex bisa disesuaikan, misal 1
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ditambahkan ke keranjang')));
                },
                icon: const Icon(Icons.add, color: Colors.green),
                label: const Text('Keranjang', style: TextStyle(color: Colors.green)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4, // Flex bisa disesuaikan, misal 2
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Beli Langsung',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}