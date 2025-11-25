// lib/modules/keuangan/pages/laporan_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/marketplace_provider.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  // --- WARNA TEMA ---
  static const Color primaryColor = Color(0xFF2D7F6A);
  static const Color contentColorCyan = Color(0xFF50E4FF);
  static const Color contentColorBlue = Color(0xFF2196F3);
  
  // Filter Waktu
  final List<String> _timeFilters = ["Mingguan", "Bulanan", "Tahunan"];
  int _selectedFilterIndex = 1; // Default "Bulanan"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Laporan Penjualan',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          
          // 1. HITUNG RINGKASAN (Sama seperti sebelumnya)
          final allTransactions = provider.transactions.where((t) => t.isSuccess).toList();
          int totalOmzet = 0;
          for (var t in allTransactions) {
            int price = int.tryParse(t.price.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            totalOmzet += price;
          }
          int totalOrder = allTransactions.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. FILTER WAKTU
                _buildTimeFilter(),
                const SizedBox(height: 20),

                // 2. KARTU OMZET (Header)
                _buildSummaryCard(totalOmzet, totalOrder),
                const SizedBox(height: 25),

                // 3. GRAFIK PENJUALAN (FL CHART KEREN)
                const Text(
                  "Grafik Penjualan", 
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18)
                ),
                const SizedBox(height: 15),
                
                // --- CONTAINER CHART ---
                Container(
                  height: 320, // Tinggi Grafik
                  padding: const EdgeInsets.only(right: 18, left: 0, top: 24, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24), // Rounded besar
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), 
                        blurRadius: 15, 
                        offset: const Offset(0, 5)
                      )
                    ],
                  ),
                  child: LineChart(
                    _mainData(), // Panggil konfigurasi chart di bawah
                    duration: const Duration(milliseconds: 250),
                  ),
                ),
                // -----------------------

                const SizedBox(height: 25),

                // 4. TOP PRODUK
                const Text("Produk Terlaris", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 15),
                _buildTopProductItem("1", "Apel Fuji Premium", "150 Terjual", "Rp 4.500.000"),
                _buildTopProductItem("2", "Jeruk Mandarin", "89 Terjual", "Rp 2.100.000"),
                _buildTopProductItem("3", "Mangga Harum Manis", "45 Terjual", "Rp 1.250.000"),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- KONFIGURASI CHART (GAYA MODERN) ---
  LineChartData _mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false, // Hilangkan garis vertikal grid biar bersih
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xffe7e8ec),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: _bottomTitleWidgets, // Label Bulan
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: _leftTitleWidgets, // Label Juta
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false, // Hilangkan border kotak
      ),
      minX: 0,
      maxX: 11, // 12 Bulan (0-11)
      minY: 0,
      maxY: 6,  // Skala Juta (0 - 6 Juta)
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),   // Jan: 3 Juta
            FlSpot(2, 2),   // Mar: 2 Juta
            FlSpot(4, 5),   // Mei: 5 Juta (Naik)
            FlSpot(6, 3.1), // Jul
            FlSpot(8, 4),   // Sep
            FlSpot(10, 3),  // Nov
            FlSpot(11, 4),  // Des
          ],
          isCurved: true, // Garis lengkung halus
          gradient: const LinearGradient(
            colors: [contentColorCyan, contentColorBlue],
          ),
          barWidth: 5,    // Ketebalan garis
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false), // Hilangkan titik-titik
          belowBarData: BarAreaData(
            show: true, // Tampilkan area warna di bawah garis
            gradient: LinearGradient(
              colors: [
                contentColorCyan.withOpacity(0.3),
                contentColorBlue.withOpacity(0.3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Label Bawah (Bulan)
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 12,
      fontFamily: 'Poppins'
    );
    Widget text;
    switch (value.toInt()) {
      case 2: text = const Text('MAR', style: style); break;
      case 5: text = const Text('JUN', style: style); break;
      case 8: text = const Text('SEP', style: style); break;
      default: text = const Text('', style: style); break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  // Label Kiri (Juta Rupiah)
  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 12,
      fontFamily: 'Poppins'
    );
    String text;
    switch (value.toInt()) {
      case 1: text = '1jt'; break;
      case 3: text = '3jt'; break;
      case 5: text = '5jt'; break;
      default: return Container();
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  // --- WIDGET UI LAINNYA ---

  Widget _buildTimeFilter() {
    return SingleChildScrollView(
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
                setState(() => _selectedFilterIndex = index);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard(int totalOmzet, int totalOrder) {
    return Container(
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
          BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
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
            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 28),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 5),
              Text("$totalOrder Transaksi Selesai", style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
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
          Container(
            width: 30, height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank == "1" ? Colors.amber : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Text(rank, style: TextStyle(fontWeight: FontWeight.bold, color: rank == "1" ? Colors.white : Colors.black54)),
          ),
          const SizedBox(width: 15),
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
          Text(revenue, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13)),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }
}