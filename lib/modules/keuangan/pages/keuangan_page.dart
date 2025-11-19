// lib/modules/keuangan/pages/keuangan_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. TAMBAHKAN IMPORT
import '../../../models/keuangan_model.dart';
import '../../../providers/keuangan_provider.dart'; // <-- 2. TAMBAHKAN IMPORT

class KeuanganPage extends StatelessWidget {
  const KeuanganPage({super.key});

  // Warna utama dari gambar
  static const Color kPrimaryColor = Color(0xFF1E605A); // Warna hijau tua
  static const Color kItemBgColor = Color(0xFFF5F5F5); // Warna abu-abu background item

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor, // Background keseluruhan scaffold adalah HIJAU
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Keuangan',
        style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white, // Bagian body ini berwarna putih
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceSection(), // <-- Panggil versi baru
            _buildChartPlaceholder(),
            _buildExpensesList(), // <-- Panggil versi baru
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Bagian "Current Balance" dan dropdown "Month"
  Widget _buildBalanceSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3. GUNAKAN CONSUMER UNTUK DATA DINAMIS
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Current Balance",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Consumer<KeuanganProvider>(
                builder: (context, provider, child) {
                  // Asumsi: Provider punya getter 'formattedBalance'
                  final String balance = provider.formattedBalance;
                  return Text(
                    balance, // <-- 4. HAPUS DUMMY DATA
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kPrimaryColor.withOpacity(0.5)),
            ),
            child: const Row(
              children: [
                Text(
                  "Month",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: kPrimaryColor, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder untuk Donut Chart
  Widget _buildChartPlaceholder() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey[200], // Lingkaran luar abu-abu
            ),
            const CircleAvatar(
              radius: 65,
              backgroundColor: Colors.white, // Lingkaran dalam putih (efek donut)
            ),
          ],
        ),
      ),
    );
  }

  // Bagian "Expenses List"
  Widget _buildExpensesList() {
    // 5. HAPUS DUMMY DATA
    // final List<KeuanganModel> expenses = KeuanganModel.dummyExpenses;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Expenses List",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // 6. GUNAKAN CONSUMER UNTUK LIST DINAMIS
          Consumer<KeuanganProvider>(
            builder: (context, provider, child) {
              // Asumsi: Provider punya getter 'expenses'
              final List<KeuanganModel> expenses = provider.expenses;

              // 7. TAMPILKAN PESAN JIKA KOSONG
              if (expenses.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Text(
                      'Tidak ada pengeluaran.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              // 8. TAMPILKAN LISTVIEW JIKA ADA DATA
              return ListView.builder(
                itemCount: expenses.length, // <-- Gunakan data provider
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildExpenseItem(expenses[index]); // <-- Gunakan data provider
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk satu item di "Expenses List" (Tidak berubah)
  Widget _buildExpenseItem(KeuanganModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kItemBgColor, // Background abu-abu
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.imageAsset,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              // Error builder jika asset tidak ditemukan
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  item.transactions,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            item.amount,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}