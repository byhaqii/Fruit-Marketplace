// lib/modules/marketplace/page/produk_list_page.dart
import 'package:flutter/material.dart';
import '../../../models/produk_model.dart';
import 'produk_detail_page.dart';

class ProdukListPage extends StatelessWidget {
  const ProdukListPage({super.key});

  // Data contoh
  List<ProdukModel> _sampleProduk() {
    return [
      for (int i = 1; i <= 6; i++) 
        ProdukModel(
          id: 'p$i',
          title: 'Organic Bananas',
          description: '7pcs, Priceg',
          price: 20000,
          imageUrl: 'https://images.unsplash.com/photo-1574226388484-93e878788e5b',
        ),
    ];
  }

  // Fungsi untuk membangun Search Bar
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8), 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produk = _sampleProduk();

    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    const double extraBottomSpace = 90.0; 

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: _buildSearchBar(context),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '4', 
                      style: TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0, 
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GridView.builder(
          itemCount: produk.length,
          padding: EdgeInsets.only(bottom: bottomPadding + extraBottomSpace),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16, 
            crossAxisSpacing: 16, 
            // PERBAIKAN OVERFLOW: Mengurangi rasio agar Card lebih tinggi
            childAspectRatio: 0.65, // Diubah dari 0.75
          ),
          itemBuilder: (context, index) {
            final item = produk[index];
            return _ProdukCard(
              produk: item,
              // INI MEMASTIKAN DETAIL BISA DIBUKA
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProdukDetailPage(produk: item),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProdukCard extends StatelessWidget {
  final ProdukModel produk;
  final VoidCallback onTap;

  const _ProdukCard({required this.produk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Menghubungkan onTap dari GridView
      child: Card(
        elevation: 0, // Menggunakan elevation 0 dan border side
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black12, width: 1),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1, 
              child: Hero(
                tag: produk.id, // Penting untuk animasi Hero
                child: Image.network(
                  produk.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              ),
            ),
            Padding(
              // Mengurangi padding vertikal untuk membantu mengatasi overflow
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start, 
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk.title, // Menggunakan data produk
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        produk.description, // Menggunakan data produk
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12), 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        produk.formattedPrice, // Menggunakan harga terformat
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
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