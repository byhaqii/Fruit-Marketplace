// lib/modules/history/pages/transaction_history_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. TAMBAHKAN IMPORT
import '../../../models/transaksi_model.dart';
import '../../../providers/marketplace_provider.dart'; // <-- 2. TAMBAHKAN IMPORT

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. HAPUS DATA DUMMY/PLACEHOLDER
    // final List<TransaksiModel> transactions = [];

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.black),
                ),
              ],
            ),
          ),
          // 4. GUNAKAN CONSUMER UNTUK MENGAMBIL DATA HISTORY
          Expanded(
            child: Consumer<MarketplaceProvider>(
              builder: (context, provider, child) {
                
                // Asumsi: Provider punya List<TransaksiModel> bernama 'transactions'
                // dan status 'isLoading'
                final bool isLoading = provider.isLoading;
                final List<TransaksiModel> transactions = provider.transactions;

                // Tampilkan loading indicator
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Tampilkan pesan jika kosong
                if (transactions.isEmpty) {
                  return const Center(child: Text('Tidak ada riwayat transaksi.'));
                }

                // Tampilkan ListView jika ada data
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: transactions.length, // <-- Gunakan data provider
                  itemBuilder: (context, index) {
                    return _buildTransactionCard(context, transactions[index]); // <-- Gunakan data provider
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransaksiModel data) {
    // Menggunakan properti isSuccess dari model
    final isSuccess = data.isSuccess;
    final buttonText = isSuccess ? 'Beri Ulasan' : 'Beli Lagi';
    final buttonColor =
        isSuccess ? Colors.green : Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  // Menggunakan properti imageUrl
                  image: NetworkImage(data.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Menggunakan properti title
                    data.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menggunakan properti date
                      Text(data.date,
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      // Menggunakan properti weight
                      Text(data.weight,
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Menggunakan properti price
                  Text(data.price,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSuccess
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          // Menggunakan properti status
                          data.status,
                          style: TextStyle(
                            color: isSuccess ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      // Action Button
                      ElevatedButton(
                        onPressed: () {
                          if (isSuccess) {
                            // Navigasi ke Halaman Rating baru
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RatingPage(transaction: data),
                              ),
                            );
                          } else {
                            // Logika "Beli Lagi"
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('$buttonText untuk ${data.title}')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(buttonText,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14)),
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

/// ==============================
/// HALAMAN RATING (BARU)
/// ==============================

class RatingPage extends StatefulWidget {
  final TransaksiModel transaction;

  const RatingPage({super.key, required this.transaction});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 0; // 0 = no rating, 1-5 = star rating
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    final String reviewText = _reviewController.text;

    // Logika untuk submit review (misal: kirim ke API)
    // Di sini kita hanya menampilkan SnackBar dan kembali

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Ulasan untuk ${widget.transaction.title} terkirim! (Rating: $_rating)'),
        backgroundColor: Colors.green,
      ),
    );

    // Kembali ke halaman sebelumnya
    Navigator.of(context).pop();
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final int starValue = index + 1;
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = starValue;
            });
          },
          icon: Icon(
            _rating >= starValue ? Icons.star : Icons.star_border,
            color: _rating >= starValue ? Colors.amber[700] : Colors.grey,
            size: 40,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Warna hijau dari gambar
    final Color primaryGreen = Colors.teal[600] ?? Colors.teal;
    final Color textGreen = Colors.teal[700] ?? Colors.teal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rating', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'How was the product?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: textGreen,
              ),
            ),
            const SizedBox(height: 16),
            _buildStarRating(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Very good product',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGreen, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _rating == 0
              ? null
              : _submitReview, // Disable jika belum ada rating
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Submit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}