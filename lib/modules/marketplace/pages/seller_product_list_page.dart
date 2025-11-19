// lib/modules/marketplace/pages/seller_product_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/marketplace_provider.dart';
import 'product_form_page.dart';

class SellerProductListPage extends StatelessWidget {
  const SellerProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produk Saya"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          // Ke halaman Form untuk TAMBAH
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormPage()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          
          // Filter produk (ideally backend should filter by seller_id, but for now we list all or filter locally)
          // Anggap semua produk di list adalah milik penjual untuk saat ini
          final products = provider.products;

          if (products.isEmpty) {
            return const Center(child: Text("Belum ada produk. Yuk tambah!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Container(width: 50, height: 50, color: Colors.grey),
                    ),
                  ),
                  title: Text(item.namaProduk, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Stok: ${item.stok} | ${item.formattedPrice}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TOMBOL EDIT
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormPage(produk: item)));
                        },
                      ),
                      // TOMBOL HAPUS
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Konfirmasi Hapus
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Hapus Produk?"),
                              content: const Text("Data yang dihapus tidak bisa dikembalikan."),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx); // Tutup dialog
                                    await provider.deleteProduct(item.id);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produk dihapus")));
                                  },
                                  child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}