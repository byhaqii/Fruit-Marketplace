// lib/modules/scan/widget/displaypicture_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../marketplace/pages/produk_list_page.dart';
import '../../marketplace/pages/produk_detail_page.dart';
import '../../../providers/marketplace_provider.dart';
import '../../../models/produk_model.dart';

class DisplayPictureScreen extends StatefulWidget {
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
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  static const Color primaryColor = Color(0xFF2D7F6A);
  late final String _resolvedQuery;

  @override
  void initState() {
    super.initState();
    _resolvedQuery = _pickQuery(widget.searchQuery, widget.ocrResult);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resolvedQuery.isNotEmpty && mounted) {
        _ensureProductsAndFilter();
      }
    });
  }

  Future<void> _ensureProductsAndFilter() async {
    final provider = context.read<MarketplaceProvider>();

    // Jika belum ada data, fetch terlebih dahulu dan tunggu selesai
    if (provider.allProducts.isEmpty) {
      print('DEBUG: Produk kosong, fetch data terlebih dahulu...');
      await provider.fetchProducts();
    }

    if (!mounted) return;
    // Jangan memperkecil list; biarkan _filterMatches bekerja di full list
    provider.filterProducts('');
  }

  String _pickQuery(String? query, String? fallback) {
    final trimmed = (query ?? '').trim();
    if (trimmed.isNotEmpty) return trimmed;
    final fallbackTrimmed = (fallback ?? '').trim();
    return fallbackTrimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.file(File(widget.imagePath)),

            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Processing Result:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.info_outline, color: primaryColor),
              title: const Text('Classified Fruit'),
              subtitle: Text(widget.ocrResult ?? 'Classification failed.'),
            ),

            ListTile(
              leading: const Icon(Icons.search, color: primaryColor),
              title: const Text('Search Recommendation'),
              subtitle: Text(
                _resolvedQuery.isNotEmpty
                    ? _resolvedQuery
                    : 'No recommendation.',
              ),
            ),

            if (_resolvedQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProdukListPage(initialSearchQuery: _resolvedQuery),
                      ),
                      (Route<dynamic> route) => route.isFirst,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Searching product: $_resolvedQuery'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: const Text(
                    'Search This Product',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Mapping ML labels ke nama produk yang mungkin ada di database
  final Map<String, List<String>> labelMappings = {
    'bali orange': [
      'bali orange',
      'jeruk bali',
      'orange',
      'jeruk',
      'orange bali',
      'pomelo',
      'grapefruit',
      'shaddock',
      'citrus maxima',
      'citrus grandis',
    ],
    'apple': ['apple', 'apel', 'appel'],
    'peach': ['peach', 'persik', 'buah persik'],
    'tomato': ['tomato', 'tomat', 'tmt'],
  };

  List<ProdukModel> _filterMatches(List<ProdukModel> products, String query) {
    final lower = query.toLowerCase();

    // Bangun alias dinamis: mapping khusus + variasi generik (hapus spasi, hapus vokal)
    final baseAliases = labelMappings[lower] ?? [lower];
    final Set<String> aliasSet = {lower, ...baseAliases};

    String _stripVowels(String s) => s.replaceAll(RegExp('[aeiou]'), '');

    for (final a in List<String>.from(aliasSet)) {
      final noSpace = a.replaceAll(' ', '');
      aliasSet.add(noSpace);
      aliasSet.add(_stripVowels(a));
      aliasSet.add(_stripVowels(noSpace));
    }

    // Prefix 3+ chars untuk fuzzy startsWith
    final Set<String> aliasPrefixes = {
      for (final a in aliasSet)
        if (a.length >= 3) a.substring(0, 3),
    };

    // DEBUG: Tampilkan semua produk yang tersedia
    print('========== SCAN DEBUG ==========');
    print('Query dari ML: $query (lowercase: $lower)');
    print('Aliases untuk dicari: ${aliasSet.toList()}');
    print('Total produk di database: ${products.length}');
    print('Daftar semua produk:');
    for (var p in products) {
      print('  - Nama: "${p.namaProduk}" | Kategori: "${p.kategori}"');
    }

    int _scoreForProduct(ProdukModel p) {
      final name = p.namaProduk.toLowerCase();
      final cat = p.kategori.toLowerCase();

      // 3 = alias contains in name/category
      final containsAlias = aliasSet.any(
        (alias) => name.contains(alias) || cat.contains(alias),
      );
      if (containsAlias) return 3;

      // 2 = name/category startsWith alias prefix (3 chars)
      final hasPrefix = aliasPrefixes.any(
        (prefix) => name.startsWith(prefix) || cat.startsWith(prefix),
      );
      if (hasPrefix) return 2;

      // 1 = overlap sederhana: alias muncul sebagai substring
      final aliasTokens = aliasSet.toList();
      final overlap = aliasTokens.any(
        (t) => name.contains(t) || cat.contains(t),
      );
      if (overlap) return 1;

      return 0;
    }

    final scored = <ProdukModel, int>{};
    for (final p in products) {
      final s = _scoreForProduct(p);
      if (s > 0) scored[p] = s;
    }

    // Urutkan berdasarkan skor tertinggi lalu nama
    final matches = scored.keys.toList()
      ..sort((a, b) {
        final scoreDiff = scored[b]! - scored[a]!;
        if (scoreDiff != 0) return scoreDiff;
        return a.namaProduk.compareTo(b.namaProduk);
      });

    print('Matches ditemukan (sorted): ${matches.length}');
    for (final p in matches) {
      print('  ✓ ${p.namaProduk} (score: ${scored[p]})');
    }
    print('=============================\n');

    return matches;
  }
}

class _MatchCard extends StatelessWidget {
  final ProdukModel produk;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _MatchCard({
    required this.produk,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Image.network(
              produk.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
        ),
        title: Text(
          produk.namaProduk,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(produk.kategori.isNotEmpty ? produk.kategori : 'Umum'),
            Text(
              produk.formattedPrice,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.add_shopping_cart,
            color: _DisplayPictureScreenState.primaryColor,
          ),
          onPressed: onAddToCart,
        ),
      ),
    );
  }
}
