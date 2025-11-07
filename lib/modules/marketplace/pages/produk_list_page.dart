// lib/modules/marketplace/page/produk_list_page.dart
import 'package:flutter/material.dart';
import '../../../models/produk_model.dart';
import 'produk_detail_page.dart';

class ProdukListPage extends StatelessWidget {
  const ProdukListPage({super.key});

  // Data contoh
  List<ProdukModel> _sampleProduk() {
    return [
      ProdukModel(
        id: 'p1',
        title: 'Strawberry Import',
        description: 'Fresh strawberry, sweet and red.',
        price: 50000,
        imageUrl: 'https://images.unsplash.com/photo-1514515728252-1b3b3f572a6d',
      ),
      ProdukModel(
        id: 'p2',
        title: 'Blueberry Grade 1',
        description: 'High quality blueberries.',
        price: 65000,
        imageUrl: 'https://images.unsplash.com/photo-1502741126161-b048400d6b7d',
      ),
      for (int i = 3; i <= 8; i++)
        ProdukModel(
          id: 'p$i',
          title: 'Strawberry Import',
          description: 'Fresh strawberry, sweet and red.',
          price: 50000,
          imageUrl: 'https://images.unsplash.com/photo-1514515728252-1b3b3f572a6d',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final produk = _sampleProduk();

    return Scaffold(
      appBar: AppBar(title: const Text('Produk List')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GridView.builder(
          itemCount: produk.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final item = produk[index];
            return _ProdukCard(
              produk: item,
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
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.4,
              child: Hero(
                tag: produk.id,
                child: FadeInImage(
                  placeholder: const AssetImage('assets/placeholder.png'),
                  image: NetworkImage(produk.imageUrl),
                  fit: BoxFit.cover,
                  imageErrorBuilder: (c, o, s) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    produk.formattedPrice,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
