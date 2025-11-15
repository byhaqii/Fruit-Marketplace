// lib/modules/keuangan/pages/keuangan_page.dart
import 'package:flutter/material.dart';
import '../../../models/keuangan_model.dart'; // Import KeuanganModel

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
        // --- PERUBAHAN ---
        // Style teks diubah menjadi hijau (kPrimaryColor)
        style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
      ),
      // --- PERUBAHAN ---
      // AppBar berwarna PUTIH
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      // --- PERUBAHAN ---
      // Tombol 'back' (leading) dihapus
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      // Container utama body yang berwarna putih (ini "card" yang Anda maksud)
      width: double.infinity,
      height: double.infinity, // Memastikan mengisi sisa area body
      decoration: const BoxDecoration(
        color: Colors.white, // Bagian body ini berwarna putih
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView( // Konten di dalam card putih bisa di-scroll
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceSection(),
            _buildChartPlaceholder(),
            _buildExpensesList(),
            const SizedBox(height: 20), // Memberi jarak di bagian bawah
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Current Balance",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                "Rp. 3.589.000,-",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
    // Ambil data dari model yang diimpor
    final List<KeuanganModel> expenses = KeuanganModel.dummyExpenses;

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
          // Menggunakan ListView.builder untuk membuat list dari dummy data
          ListView.builder(
            itemCount: expenses.length, // Gunakan data dari model
            shrinkWrap: true, // Penting agar ListView di dalam Column
            physics: const NeverScrollableScrollPhysics(), // Agar scroll utama yg bekerja
            itemBuilder: (context, index) {
              return _buildExpenseItem(expenses[index]); // Gunakan data dari model
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk satu item di "Expenses List"
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