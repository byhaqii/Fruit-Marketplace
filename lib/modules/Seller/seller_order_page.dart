import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaksi_model.dart';
import '../../providers/marketplace_provider.dart';

class SellerOrderPage extends StatefulWidget {
  const SellerOrderPage({super.key});

  @override
  State<SellerOrderPage> createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> {
  final List<String> _filters = ["Semua", "Menunggu Konfirmasi", "Diproses", "Dikirim", "Selesai", "Dibatalkan"];
  int _selectedFilterIndex = 0;

  // Warna Konsisten
  static const Color primaryColor = Color(0xFF2D7F6A);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _refreshData());
  }

  Future<void> _refreshData() async {
    await Provider.of<MarketplaceProvider>(context, listen: false).fetchSellerTransactions();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER
            Container(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              decoration: const BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)), 
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: primaryColor), 
                          onPressed: () => Navigator.pop(context)
                        ),
                        const Text(
                          "Pesanan Masuk", 
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 20, color: primaryColor)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Filter Tabs
                  SingleChildScrollView(
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
                ],
              ),
            ),
            
            // 2. LIST PESANAN
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
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
                      itemBuilder: (context, index) => _buildSellerOrderCard(context, orders[index], provider)
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
                "Belum ada pesanan", 
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
              )
            ]
          ),
        ),
      ],
    );
  }

  Widget _buildSellerOrderCard(BuildContext context, TransaksiModel trx, MarketplaceProvider provider) {
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
                    const Icon(Icons.person_outline, size: 18, color: Colors.black54), 
                    const SizedBox(width: 8), 
                    Text("Pesanan #${trx.id}", style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13))
                  ]
                ), 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                  decoration: BoxDecoration(
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
          
          // Footer Actions (Tombol)
          if (trx.isWaiting || trx.isProcessed) 
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15), 
              child: Row(
                children: [
                  // --- TOMBOL UNTUK STATUS 'WAITING' ---
                  if (trx.isWaiting) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirmReject(context, provider, trx.id), 
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ), 
                        child: const Text("Tolak", style: TextStyle(color: Colors.red))
                      )
                    ), 
                    const SizedBox(width: 10), 
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus(context, provider, trx.id, 'Diproses', "Pesanan diterima & diproses"), 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ), 
                        child: const Text("Terima", style: TextStyle(color: Colors.white))
                      )
                    )
                  ] 
                  // --- TOMBOL UNTUK STATUS 'PROCESSED' ---
                  else if (trx.isProcessed) 
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus(context, provider, trx.id, 'Dikirim', "Pesanan berhasil dikirim"), 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ), 
                        child: const Text("Kirim Pesanan", style: TextStyle(color: Colors.white))
                      )
                    )
                ]
              )
            )
        ],
      ),
    );
  }

  // --- LOGIC HELPER ---

  // Fungsi Update Status dengan Loading & Error Handling
  Future<void> _updateStatus(BuildContext context, MarketplaceProvider provider, int id, String status, String successMessage) async {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white))
    );

    try {
      // Asumsi: provider.updateOrderStatus mengembalikan Future (awaitable)
      await provider.updateOrderStatus(id, status);
      
      if (mounted) {
        Navigator.pop(context); // Tutup Loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(successMessage),
          backgroundColor: primaryColor,
        ));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup Loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Gagal memproses: $e"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // Konfirmasi sebelum menolak pesanan
  void _confirmReject(BuildContext context, MarketplaceProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tolak Pesanan?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Pesanan akan dibatalkan dan tidak dapat dikembalikan."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Batal", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(context, provider, id, 'Dibatalkan', "Pesanan ditolak");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Tolak", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}