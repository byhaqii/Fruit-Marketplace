// lib/modules/history/pages/transaction_history_page.dart

import 'package:flutter/material.dart';
import '../../../models/transaksi_model.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menghilangkan data dummy. Menggunakan list kosong sebagai ganti
    // simulasi data yang akan dimuat dari API.
    final List<TransaksiModel> transactions = [];

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
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('Tidak ada riwayat transaksi.')) // Tambahkan pesan jika kosong
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: transactions.length,
                    // Mengoper objek TransaksiModel
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(context, transactions[index]);
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
    final buttonColor = isSuccess ? Colors.green : Theme.of(context).colorScheme.primary;

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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menggunakan properti date
                      Text(data.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      // Menggunakan properti weight
                      Text(data.weight, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Menggunakan properti price
                  Text(data.price, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            // Menggunakan properti title
                            SnackBar(content: Text('$buttonText untuk ${data.title}')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 14)),
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
