import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../models/transaksi_model.dart';
import '../../providers/marketplace_provider.dart';

class SellerOrderPage extends StatefulWidget {
  const SellerOrderPage({super.key});

  @override
  State<SellerOrderPage> createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> {
  final List<String> _filters = [
    "All",
    "Pending",
    "Processing",
    "Shipped",
    "Completed",
    "Cancelled",
  ];
  int _selectedFilterIndex = 0;

  // Warna Konsisten
  static const Color primaryColor = Color(0xFF2D7F6A);

  @override
  void initState() {
    super.initState();
    // Ambil pesanan MASUK untuk penjual saat halaman dibuka
    Future.microtask(() => _refreshData());
  }

  Future<void> _refreshData() async {
    await Provider.of<MarketplaceProvider>(
      context,
      listen: false,
    ).fetchSellerTransactions();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(25, 50, 25, 15),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "My Orders",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: primaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Add search functionality here
                        },
                        icon: const Icon(
                          Icons.search,
                          color: primaryColor,
                          size: 28,
                        ),
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
                          onTap: () =>
                              setState(() => _selectedFilterIndex = index),
                          child: Column(
                            children: [
                              Text(
                                _filters[index],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 14,
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.grey[400],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
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
                  if (provider.isLoading) {
                    return ColoredBox(
                      color: const Color(0xFF2D7F6A),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 240),
                          Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  List<TransaksiModel> orders = provider.transactions;

                  // Logic Filter
                  if (_selectedFilterIndex != 0) {
                    final filterStatus = _filters[_selectedFilterIndex];
                    orders = orders.where((t) {
                      if (filterStatus == "Pending") return t.isWaiting;
                      if (filterStatus == "Processing") return t.isProcessed;
                      if (filterStatus == "Shipped") return t.isShipped;
                      if (filterStatus == "Completed") return t.isSuccess;
                      if (filterStatus == "Cancelled") return t.isCancelled;
                      return true;
                    }).toList();
                  }

                  if (orders.isEmpty) {
                    return LayoutBuilder(
                      builder: (ctx, constraints) {
                        return ColoredBox(
                          color: const Color(0xFF2D7F6A),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: _buildEmptyState(),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return Container(
                    color: const Color(0xFF2D7F6A),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: orders.length,
                      itemBuilder: (context, index) => _buildSellerOrderCard(
                        context,
                        orders[index],
                        provider,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.white),
          SizedBox(height: 20),
          Text(
            "No orders yet",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerOrderCard(
    BuildContext context,
    TransaksiModel trx,
    MarketplaceProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
                    const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Order #${trx.id}",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: trx.isSuccess
                        ? primaryColor.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trx.status,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: trx.isSuccess ? primaryColor : Colors.orange,
                    ),
                  ),
                ),
              ],
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
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trx.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Total: ${trx.price}",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                        onPressed: () =>
                            _confirmReject(context, provider, trx.id),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Reject",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus(
                          context,
                          provider,
                          trx.id,
                          'Diproses',
                          "Order accepted & processing",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Accept",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ]
                  // --- TOMBOL UNTUK STATUS 'PROCESSED' ---
                  else if (trx.isProcessed)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus(
                          context,
                          provider,
                          trx.id,
                          'Dikirim',
                          "Order successfully shipped",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Ship Order",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- LOGIC HELPER ---

  // Fungsi Update Status dengan Loading & Error Handling
  Future<void> _updateStatus(
    BuildContext context,
    MarketplaceProvider provider,
    int id,
    String status,
    String successMessage,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      // Asumsi: provider.updateOrderStatus mengembalikan Future (awaitable)
      await provider.updateOrderStatus(id, status);

      if (mounted) {
        Navigator.pop(context); // Tutup Loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: primaryColor,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup Loading
        final serverMsg =
            e.response?.data?.toString() ?? e.message ?? 'Failed to process';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(serverMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to process: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Konfirmasi sebelum menolak pesanan
  void _confirmReject(
    BuildContext context,
    MarketplaceProvider provider,
    int id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Reject Order?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Order will be cancelled and cannot be reversed."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(
                context,
                provider,
                id,
                'Dibatalkan',
                "Order rejected",
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
