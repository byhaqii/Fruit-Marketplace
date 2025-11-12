// lib/modules/marketplace/page/produk_list_page.dart
import 'package:flutter/material.dart';
import '../../../models/produk_model.dart';
import 'produk_detail_page.dart';

class ProdukListPage extends StatelessWidget {
  const ProdukListPage({super.key});

  // Data dari ProdukSeeder.php yang dibatasi hanya 3
  List<ProdukModel> _getProdukFromSeeder() {
    const String dummyImageUrl =
        'https://images.unsplash.com/photo-1619665671569-808848d689b0';

    // Hanya berisi 3 produk pertama
    final baseProducts = <ProdukModel>[
      ProdukModel(
        id: 'p1',
        title: 'Keripik Singkong Pedas',
        description: 'Keripik singkong buatan rumahan, renyah dan pedas.',
        price: 12000,
        imageUrl: dummyImageUrl,
        category: 'Makanan Ringan',
      ),
      ProdukModel(
        id: 'p2',
        title: 'Sayur Bayam Segar',
        description: 'Bayam organik dipanen pagi hari dari kebun sendiri.',
        price: 7500,
        imageUrl: dummyImageUrl,
        category: 'Sayuran',
      ),
      ProdukModel(
        id: 'p3',
        title: 'Jasa Servis Komputer',
        description:
            'Menerima servis laptop dan komputer, instalasi software dan hardware.',
        price: 150000,
        imageUrl: dummyImageUrl,
        category: 'Jasa',
      ),
    ];

    return baseProducts; // Mengembalikan hanya 3 produk
  }

  Widget _buildSearchBar() {
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
    final produkList = _getProdukFromSeeder();
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const extraBottomSpace = 90.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _buildSearchBar(),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                    child: const Text(
                      '4',
                      style: TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
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
          itemCount: produkList.length,
          padding: EdgeInsets.only(bottom: bottomPadding + extraBottomSpace),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65, // lebih tinggi agar card tidak overflow
          ),
          itemBuilder: (context, index) {
            final item = produkList[index];
            return _ProdukCard(
              produk: item,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProdukDetailPage(produk: item)),
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
      onTap: onTap,
      child: Card(
        elevation: 0,
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
                tag: produk.id,
                child: Image.network(
                  produk.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    produk.category,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        produk.formattedPrice,
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
