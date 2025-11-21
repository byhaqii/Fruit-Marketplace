// lib/modules/keuangan/pages/laporan_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pastikan package intl sudah ada di pubspec.yaml
import '../../../providers/marketplace_provider.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  // --- KONSTANTA GAYA ---
  static const Color primaryColor = Color(0xFF2D7F6A);
  
  // Filter Waktu (UI Only untuk saat ini)
  final List<String> _timeFilters = ["Hari Ini", "Minggu Ini", "Bulan Ini", "Semua"];
  int _selectedFilterIndex = 3; // Default "Semua"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Abu-abu sangat muda
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Laporan Penjualan',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Export PDF Segera Hadir"))
              );
            },
          )
        ],
      ),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          // 1. AMBIL DATA TRANSAKSI
          // Filter hanya yang statusnya 'Selesai' (Uang masuk)
          final allTransactions = provider.transactions.where((t) => t.isSuccess).toList();
          
          // 2. HITUNG RINGKASAN
          int totalOmzet = 0;
          for (var t in allTransactions) {
            // Bersihkan string harga (misal "Rp 15.000" -> 15000)
            int price = int.tryParse(t.price.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            totalOmzet += price;
          }

          int totalOrder = allTransactions.length;
          
          // Hitung Pesanan Dibatalkan/Gagal
          int failedOrder = provider.transactions.where((t) => t.isCancelled).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. FILTER WAKTU
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_timeFilters.length, (index) {
                      final isSelected = _selectedFilterIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(
                            _timeFilters[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontFamily: 'Poppins',
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          backgroundColor: Colors.white,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedFilterIndex = index;
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
                
                const SizedBox(height: 20),

                // 2. KARTU OMZET UTAMA
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Pendapatan Bersih",
                        style: TextStyle(color: Colors.white70, fontFamily: 'Poppins', fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatCurrency(totalOmzet),
                        style: const TextStyle(
                          color: Colors.white, 
                          fontFamily: 'Poppins', 
                          fontWeight: FontWeight.bold, 
                          fontSize: 28
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildMiniStat(Icons.check_circle, "$totalOrder Selesai", Colors.white),
                          const SizedBox(width: 20),
                          _buildMiniStat(Icons.cancel, "$failedOrder Dibatalkan", Colors.orange[100]!),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 3. GRAFIK VISUAL (Simpel Bar Chart Manual)
                const Text("Tren Penjualan", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBarColumn("Sen", 40),
                      _buildBarColumn("Sel", 60),
                      _buildBarColumn("Rab", 30),
                      _buildBarColumn("Kam", 80),
                      _buildBarColumn("Jum", 50),
                      _buildBarColumn("Sab", 90, isHigh: true),
                      _buildBarColumn("Min", 70),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 4. TOP PRODUK (Dummy Data Visual)
                const Text("Produk Terlaris", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 15),
                _buildTopProductItem("1", "Apel Fuji Premium", "150 Terjual", "Rp 4.500.000"),
                _buildTopProductItem("2", "Jeruk Mandarin", "89 Terjual", "Rp 2.100.000"),
                _buildTopProductItem("3", "Mangga Harum Manis", "45 Terjual", "Rp 1.250.000"),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildMiniStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: color, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Widget Batang Grafik Sederhana
  Widget _buildBarColumn(String day, double percentage, {bool isHigh = false}) {
    return Column(
      children: [
        Container(
          width: 12,
          height: percentage, // Tinggi batang
          decoration: BoxDecoration(
            color: isHigh ? const Color(0xFF2D7F6A) : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: Colors.grey[600], 
            fontSize: 12, 
            fontFamily: 'Poppins'
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductItem(String rank, String name, String sales, String revenue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 30, height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank == "1" ? Colors.amber : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Text(
              rank,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: rank == "1" ? Colors.white : Colors.black54
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Info Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(sales, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          // Pendapatan Produk
          Text(revenue, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13)),
        ],
      ),
    );
  }

  // Helper Format Rupiah
  String _formatCurrency(int amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }
}