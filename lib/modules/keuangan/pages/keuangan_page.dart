// lib/modules/keuangan/pages/keuangan_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/keuangan_model.dart';
import '../../../providers/keuangan_provider.dart';

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({super.key});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  // Warna tema halaman ini
  static const Color kPrimaryColor = Color(0xFF1E605A); 
  static const Color kItemBgColor = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    // Refresh data saat halaman dibuka
    Future.microtask(() => 
      Provider.of<KeuanganProvider>(context, listen: false).fetchKeuanganData()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        title: const Text('Keuangan', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10), // Sedikit margin atas
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Consumer<KeuanganProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. BAGIAN SALDO
                  _buildBalanceSection(provider.formattedBalance),
                  
                  // 2. CHART (Visualisasi Sederhana)
                  _buildChartPlaceholder(),
                  
                  const SizedBox(height: 20),

                  // 3. DAFTAR TRANSAKSI
                  const Text(
                    "Riwayat Transaksi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  if (provider.expenses.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.expenses.length,
                      itemBuilder: (context, index) {
                        return _buildExpenseItem(provider.expenses[index]);
                      },
                    ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceSection(String balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Colors.grey, size: 18),
                  const SizedBox(width: 5),
                  Text("Total Saldo", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                balance,
                style: const TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // Tombol Top Up Kecil
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Top Up Segera Hadir")));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: kPrimaryColor),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 25),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran Luar (Background)
          SizedBox(
            width: 150, height: 150,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 12,
              color: Colors.grey[100],
            ),
          ),
          // Lingkaran Data (Persentase - Simulasi)
          SizedBox(
            width: 150, height: 150,
            child: const CircularProgressIndicator(
              value: 0.75, // 75%
              strokeWidth: 12,
              color: kPrimaryColor,
              backgroundColor: Colors.transparent,
            ),
          ),
          // Teks Tengah
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("75%", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryColor)),
              Text("Pengeluaran", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildExpenseItem(KeuanganModel item) {
    // Menentukan warna nominal (Hijau jika +, Merah/Hitam jika -)
    final bool isIncome = item.amount.contains('+');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kItemBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            // Menggunakan Icon bawaan sebagai fallback jika gambar aset tidak ada
            child: Icon(
              item.amount.contains('+') ? Icons.arrow_downward : Icons.arrow_upward,
              color: item.amount.contains('+') ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 15),
          
          // Detail Transaksi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  item.transactions,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          
          // Nominal
          Text(
            item.amount,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 15,
              color: isIncome ? Colors.green : Colors.black87
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: const [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 10),
            Text('Belum ada riwayat transaksi.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}