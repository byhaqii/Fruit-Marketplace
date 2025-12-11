// lib/modules/history/pages/transaction_history_page.dart

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
  // --- STATE FILTER (SAMA DENGAN SELLER) ---
  final List<String> _filters = ["Semua", "Menunggu Konfirmasi", "Diproses", "Dikirim", "Selesai", "Dibatalkan"];
  int _selectedFilterIndex = 0;

  // Warna Konsisten
  static const Color primaryColor = Color(0xFF2D7F6A);

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Memuat data transaksi pembeli saat halaman dibuka
    // Ini memastikan status terbaru ditarik dari server
    Future.microtask(() => _refreshData());
  }

  Future<void> _refreshData() async {
    // Memanggil fetchTransactions() yang mengambil data dari endpoint pembeli (/transaksi)
    await Provider.of<MarketplaceProvider>(context, listen: false).fetchTransactions();
  }

  // Widget Card Transaksi Didefinisikan di sini (menggantikan TransactionCard)
  Widget _buildTransactionCard(BuildContext context, TransaksiModel trx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.black54), 
                    const SizedBox(width: 8), 
                    Text("Pesanan #${trx.orderId}", style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13))
                  ]
                ), 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                  decoration: BoxDecoration(
                    // Logic to set color based on status
                    color: trx.isSuccess ? primaryColor.withOpacity(0.1) : Colors.orange.withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(8)
                  ), 
                  child: Text(
                    trx.status, 
                    style: TextStyle(
                      fontFamily: 'Poppins', 
                      fontSize: 11, 
                      fontWeight: FontWeight.w600, 
                      color: trx.isSuccess ? primaryColor : Colors.orange
                    )
                  )
                )
              ]
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          // Body Card (Produk)
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), 
                  child: Image.network(
                    // Base URL sudah di-handle oleh Dio di ApiClient
                    trx.imageUrl, 
                    width: 70, height: 70, fit: BoxFit.cover, 
                    errorBuilder: (_,__,___) => Container(width: 70, height: 70, color: Colors.grey[200])
                  )
                ), 
                const SizedBox(width: 12), 
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text(
                        trx.title, 
                        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14), 
                        maxLines: 2, overflow: TextOverflow.ellipsis
                      ), 
                      const SizedBox(height: 4), 
                      Text(
                        "Total: ${trx.price}", 
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: primaryColor, fontWeight: FontWeight.w600)
                      )
                    ]
                  )
                )
              ]
            ),
          ),
          
          // Footer (Aksi pembeli: Tombol Terima Barang/Batalkan dapat ditambahkan di sini)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Riwayat Transaksi",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. FILTER TABS
            Container(
              padding: const EdgeInsets.only(top: 5, bottom: 15),
              decoration: const BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)), 
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: List.generate(_filters.length, (index) { 
                    final isSelected = _selectedFilterIndex == index; 
                    return Padding(
                      padding: const EdgeInsets.only(right: 20), 
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilterIndex = index), 
                        child: Column(
                          children: [
                            Text(
                              _filters[index], 
                              style: TextStyle(
                                fontFamily: 'Poppins', 
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                                fontSize: 14, 
                                color: isSelected ? primaryColor : Colors.grey[400]
                              )
                            ), 
                            if (isSelected) 
                              Container(
                                margin: const EdgeInsets.only(top: 4), 
                                width: 4, height: 4, 
                                decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle)
                              )
                          ]
                        )
                      )
                    );
                  })
                ),
              ),
            ),
            
            // 2. LIST TRANSAKSI
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData, // Pull-to-refresh memanggil fetch terbaru
                color: primaryColor,
                child: Consumer<MarketplaceProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white));
                    
                    List<TransaksiModel> orders = provider.transactions;
                    
                    // Logic Filter
                    if (_selectedFilterIndex != 0) {
                      final filterStatus = _filters[_selectedFilterIndex];
                      orders = orders.where((t) {
                         if (filterStatus == "Menunggu Konfirmasi") return t.isWaiting;
                         if (filterStatus == "Diproses") return t.isProcessed;
                         if (filterStatus == "Dikirim") return t.isShipped;
                         if (filterStatus == "Selesai") return t.isSuccess;
                         if (filterStatus == "Dibatalkan") return t.isCancelled;
                         return true;
                      }).toList();
                    }
                    
                    if (orders.isEmpty) return _buildEmptyState();
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(20), 
                      itemCount: orders.length, 
                      itemBuilder: (context, index) => _buildTransactionCard(context, orders[index]) 
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    // Menggunakan ListView agar RefreshIndicator tetap berfungsi
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: const [
              Icon(Icons.assignment_outlined, size: 80, color: Colors.white70), 
              SizedBox(height: 20), 
              Text(
                "Belum ada riwayat transaksi", 
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
              )
            ]
          ),
        ),
      ],
    );
  }
}