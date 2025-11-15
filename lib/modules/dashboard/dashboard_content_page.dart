// lib/modules/dashboard/dashboard_content_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/user_model.dart'; // Path model ini benar

// --- 1. IMPORT (Sudah benar) ---
import '../marketplace/pages/produk_list_page.dart';
import '../marketplace/pages/produk_detail_page.dart';

class DashboardContentPage extends StatelessWidget {
  // 1. Tambahkan parameter callback
  final VoidCallback onSeeAllTapped;

  const DashboardContentPage({
    super.key,
    required this.onSeeAllTapped, // Jadikan required
  });

  // Warna utama dari gambar
  static const Color kPrimaryColor = Color(0xFF1E605A);
  static const Color kAnalyticsCardColor1 = Color(0xFF4C8A82);
  static const Color kAnalyticsCardColor2 = Color(0xFF1E7B70);
  static const Color kChipSelectedColor = Color(0xFFFFFFFF);
  static const Color kChipUnselectedColor = Color(0xFF4C8A82);
  static const Color kBannerImageBackground = Color(0xFFF3F3F3);

  @override
  Widget build(BuildContext context) {
    final UserModel user = UserModel.simulatedApiUser;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: KARTU PUTIH STATIS (Welcome) ---
            _buildWelcomeCard(user),

            // --- BAGIAN 2: KONTEN SCROLLABLE (Analytics + Sisa) ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // --- KARTU PUTIH SCROLLABLE (Analytics) ---
                  _buildAnalyticsCard(),

                  // --- Sisa Konten di Latar Hijau ---
                  const SizedBox(height: 24),
                  _buildBannerSection(),
                  const SizedBox(height: 12),
                  _buildBannerIndicator(),
                  const SizedBox(height: 24),

                  // Bagian "Recommended"
                  _buildSectionHeader(
                    context,
                    title: 'Recommended',
                    actionText: 'See All',
                    onTapAction: onSeeAllTapped, // Kirim callback-nya ke sini
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  _buildRecommendedGrid(context),
                  const SizedBox(height: 24),

                  // Bagian "Order Again"
                  _buildSectionHeader(
                    context,
                    title: 'Order Again',
                    actionText: 'Show All',
                    onTapAction: null, // "Order Again" tidak melakukan apa-apa
                  ),
                  const SizedBox(height: 16),
                  _buildOrderAgainList(),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KARTU 1 (STATIS: Welcome) ---
  Widget _buildWelcomeCard(UserModel user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user.name}',
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMMM', 'id_ID').format(DateTime.now()),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage('https://picsum.photos/200/200'),
          ),
        ],
      ),
    );
  }

  // --- WIDGET KARTU 2 (SCROLLABLE: Analytics) ---
  Widget _buildAnalyticsCard() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Analytics',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Monthly',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down,
                      color: Colors.grey, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnalyticsItem('Transaction\nSuccess', kAnalyticsCardColor1),
              _buildAnalyticsItem('Response\nRate', kAnalyticsCardColor1),
              _buildAnalyticsItem('Happy\nFeedback', kAnalyticsCardColor2),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- WIDGET BUILDER LAINNYA ---
  Widget _buildAnalyticsItem(String title, Color color) {
    return Container(
      width: 105,
      height: 125,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Limited time!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Grab it Fast',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Get Spesial Offer',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All of Fruits type Available',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 130,
              height: 140,
              color: kBannerImageBackground,
              child: Image.asset(
                'assets/fruit_bowl.png', // Placeholder (Ganti dengan path asset Anda)
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                        child:
                            Icon(Icons.broken_image, color: Colors.grey)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(isActive: true),
        _buildDot(isActive: false),
        _buildDot(isActive: false),
      ],
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  // --- 3. UBAH FUNGSI INI ---
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String actionText,
    VoidCallback? onTapAction, // Parameter callback opsional
  }) {
    Widget actionWidget;

    // Jika onTapAction DIBERIKAN (yaitu untuk "Recommended")
    if (onTapAction != null) {
      // Gunakan TextButton untuk mendapatkan perubahan kursor di web
      actionWidget = TextButton(
        onPressed: onTapAction,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerRight,
        ),
        child: Text(
          actionText,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );
    } else {
      // Jika tidak, tampilkan sebagai teks biasa (untuk "Order Again")
      actionWidget = Text(
        actionText,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actionWidget, // Tampilkan widget (TextButton atau Text)
        ],
      ),
    );
  }

  // --- Sisa fungsi tidak berubah ---

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildChip('All', isSelected: true),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        backgroundColor:
            isSelected ? kChipSelectedColor : kChipUnselectedColor,
        labelStyle: TextStyle(
          color: isSelected ? kPrimaryColor : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildRecommendedGrid(BuildContext context) {
    final productsToShow = kDummyProducts.take(4).toList();
    return GridView.builder(
      itemCount: productsToShow.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.67,
      ),
      itemBuilder: (context, index) {
        final produk = productsToShow[index];
        return ProdukCard(
          produk: produk,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProdukDetailPage(produk: produk),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderAgainList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildOrderAgainCard(
            totalProduk: 2,
            totalHarga: "20.000,-",
          ),
          const SizedBox(height: 16),
          _buildOrderAgainCard(
            totalProduk: 1,
            totalHarga: "10.000,-",
          ),
        ],
      ),
    );
  }

  Widget _buildOrderAgainCard(
      {required int totalProduk, required String totalHarga}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  'assets/banana.png', // Placeholder
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                          child:
                              Icon(Icons.broken_image, color: Colors.grey)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Organic Bananas',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Fresh Banana India\n0,5 kg (Pcs)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total $totalProduk Produk: Rp. $totalHarga',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lihat Semua', style: TextStyle(color: Colors.grey)),
              const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: const Text('Nilai',
                    style: TextStyle(color: kPrimaryColor)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Beli Lagi',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }
}