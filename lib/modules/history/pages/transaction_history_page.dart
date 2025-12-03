import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/transaksi_model.dart';
import '../../../providers/marketplace_provider.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pastikan Provider sudah di-load di main.dart
      Provider.of<MarketplaceProvider>(context, listen: false).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.transactions.isEmpty) {
            return const Center(child: Text('Belum ada transaksi.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.transactions.length,
            itemBuilder: (context, index) {
              return _buildTransactionCard(
                  context, provider.transactions[index], provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransaksiModel data, MarketplaceProvider provider) {
    // Tentukan warna berdasarkan status
    Color statusColor = Colors.grey;
    if (data.isWaiting) statusColor = Colors.orange;
    else if (data.isProcessed) statusColor = Colors.blue;
    // PERBAIKAN: Gunakan isReceivable (Dikirim atau Tiba di tujuan) untuk warna ungu
    else if (data.isReceivable) statusColor = Colors.purple; 
    else if (data.isSuccess) statusColor = Colors.green;
    else if (data.isCancelled) statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                    image: DecorationImage(
                      image: NetworkImage(data.imageUrl),
                      fit: BoxFit.cover,
                      onError: (e, s) {}, // Handle error gambar
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Detail
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(data.date,
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(data.price,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      
                      // Tag Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // --- LOGIKA TOMBOL (Action Buttons) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                
                // 1. Tombol Cancel (Hanya jika Menunggu Konfirmasi)
                if (data.isWaiting)
                  ElevatedButton(
                    onPressed: () async {
                       bool confirm = await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Batalkan Pesanan?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Tidak")),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Ya")),
                            ],
                          )) ?? false;
                          
                       if(confirm) {
                         // Panggil fungsi cancel di provider
                         await provider.cancelOrder(data.id);
                       }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Batalkan", style: TextStyle(color: Colors.white)),
                  ),

                // 2. Tombol Terima Barang (Hanya jika Dikirim atau Tiba di tujuan)
                // PERBAIKAN: Menggunakan isReceivable
                if (data.isReceivable)
                  ElevatedButton(
                    onPressed: () async {
                       // Panggil fungsi terima di provider
                       await provider.markAsReceived(data.id);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Terima Barang", style: TextStyle(color: Colors.white)),
                  ),

                // 3. Tombol Ulasan (Hanya jika Selesai)
                // PERBAIKAN: Menggunakan isSuccess
                if (data.isSuccess)
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RatingPage(transaction: data),
                        ),
                      );
                    },
                    child: const Text("Beri Ulasan"),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --- CLASS RATING PAGE (Tetap sama, tidak perlu diubah) ---
class RatingPage extends StatefulWidget {
  final TransaksiModel transaction;
  const RatingPage({super.key, required this.transaction});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  // ... (Kode RatingPage Anda sudah bagus, gunakan yang tadi) ...
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
     // ... (Isi widget RatingPage Anda) ...
     return Scaffold(
        appBar: AppBar(title: const Text("Rating")),
        body: Center(child: Text("Rating Page for ${widget.transaction.title}")),
     );
  }
}