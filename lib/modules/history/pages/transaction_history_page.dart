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
  static const Color kPrimaryColor = Color(0xFF2D7F6A);

  // --- STATE UNTUK FILTER & SEARCH ---
  String _selectedStatus = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filterStatuses = [
    'All',
    'Pending',
    'Active', // Kombinasi Diproses, Dikirim, Tiba di tujuan
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketplaceProvider>(
        context,
        listen: false,
      ).fetchTransactions();
    });
    // Tambahkan listener untuk otomatis memfilter saat mengetik
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Memanggil fetchTransactions() yang mengambil data dari endpoint pembeli (/transaksi)
    await Provider.of<MarketplaceProvider>(context, listen: false).fetchTransactions();
  }

  // --- LOGIKA FILTER TRANSAKSI GABUNGAN ---
  List<TransaksiModel> _getFilteredTransactions(
    List<TransaksiModel> all,
    String status,
    String query,
  ) {
    final lowerQuery = query.toLowerCase();

    return all.where((data) {
      // 1. Filter Status
      bool matchesStatus;
      if (status == 'All') {
        matchesStatus = true;
      } else if (status == 'Pending') {
        matchesStatus = data.isWaiting;
      } else if (status == 'Active') {
        // Active = Sedang Diproses, Dikirim, atau Tiba di tujuan (isProcessed & isReceivable)
        matchesStatus = data.isProcessed || data.isReceivable;
      } else if (status == 'Completed') {
        matchesStatus = data.isSuccess;
      } else if (status == 'Cancelled') {
        matchesStatus = data.isCancelled;
      } else {
        matchesStatus = true;
      }

      // 2. Filter Pencarian (Order ID atau Judul Pesanan)
      final matchesQuery =
          lowerQuery.isEmpty ||
          data.orderId.toLowerCase().contains(lowerQuery) ||
          data.title.toLowerCase().contains(lowerQuery);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text(
          "Transaction History",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading &&
              provider.transactions.isEmpty &&
              _searchController.text.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          final filteredList = _getFilteredTransactions(
            provider.transactions,
            _selectedStatus,
            _searchController.text,
          );

          return Column(
            children: [
              // HEADER SUMMARY
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pesanan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filteredList.length} transactions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_alt_outlined,
                            color: kPrimaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedStatus,
                            style: const TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 1. SEARCH BAR
              _buildSearchBar(),

              // 2. FILTER CHIPS
              _buildFilterChips(),

              // 3. TRANSACTION LIST
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.fetchTransactions();
                  },

                  child: filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedStatus == 'All'
                                    ? 'No transaction history yet'
                                    : 'No transactions with status\n"$_selectedStatus"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return _buildTransactionCard(
                              context,
                              filteredList[index],
                              provider,
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- UI HELPER: Search Bar ---
  // --- UI HELPER: Search Bar (DIPERBAIKI) ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          // 1. KUNCI: Menambahkan ini agar teks & icon sejajar di tengah (center)
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            hintText: 'Search Order ID or Product Name',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            // 2. Set padding jadi kosong agar tidak bentrok dengan textAlignVertical
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  // --- UI HELPER: Filter Chips ---
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterStatuses.length,
        itemBuilder: (context, index) {
          final status = _filterStatuses[index];
          final isSelected = _selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStatus = status;
                });
              },
              child: Chip(
                label: Text(
                  status,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: isSelected ? kPrimaryColor : Colors.grey[200],
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                side: isSelected
                    ? BorderSide.none
                    : BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    TransaksiModel data,
    MarketplaceProvider provider,
  ) {
    // Tentukan warna berdasarkan status
    Color statusColor = Colors.grey;
    if (data.isWaiting)
      statusColor = Colors.orange;
    else if (data.isProcessed)
      statusColor = Colors.blue;
    else if (data.isReceivable)
      statusColor = Colors.purple;
    else if (data.isSuccess)
      statusColor = Colors.green;
    else if (data.isCancelled)
      statusColor = Colors.red;

    final int totalItems = data.items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigasi ke detail transaksi (jika detail page sudah dibuat)
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Order ID & Status)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Order ID: #${data.orderId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      data.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 20),

              // 2. ITEM SUMMARY
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      data.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (e, s, t) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title, // Title yang sudah diperbaiki (misal: "Apel dan 2 Produk Lainnya")
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: kPrimaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalItems Item | ${data.date}', // Tampilkan total item dan tanggal
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 20),

              // 3. FOOTER (Total Price & Buttons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Payment',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        data.price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),

                  // Action Buttons (Condensed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 1. Tombol Cancel (Outlined)
                      if (data.isWaiting)
                        _buildActionButton(
                          context,
                          'Cancel',
                          Colors.red,
                          () async {
                            bool confirm =
                                await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Cancel Order?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text("No"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text(
                                          "Yes",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;

                            if (confirm) await provider.cancelOrder(data.id);
                          },
                          isFilled: false,
                        ),

                      // 2. Tombol Terima Barang (Filled, Primary Action)
                      if (data.isReceivable)
                        _buildActionButton(
                          context,
                          'Receive',
                          kPrimaryColor,
                          () async {
                            await provider.markAsReceived(data.id);
                          },
                          isFilled: true,
                        ),

                      // 3. Tombol Ulasan (Outlined)
                      if (data.isSuccess)
                        _buildActionButton(
                          context,
                          'Review',
                          Colors.blueGrey,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RatingPage(transaction: data),
                              ),
                            );
                          },
                          isFilled: false,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widget baru untuk Tombol Aksi
  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed, {
    bool isFilled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: isFilled
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(text, style: TextStyle(fontSize: 12, color: color)),
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
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rating")),
      body: Center(child: Text("Rating Page for ${widget.transaction.title}")),
    );
  }
}
