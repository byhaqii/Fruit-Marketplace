// lib/modules/dashboard/dashboard_content_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // <-- 1. TAMBAHKAN IMPORT
import '../../../models/user_model.dart';
import '../../../models/produk_model.dart'; // <-- 2. TAMBAHKAN IMPORT
import '../../../models/transaksi_model.dart'; // <-- 3. TAMBAHKAN IMPORT
import '../marketplace/pages/produk_list_page.dart';
import '../marketplace/pages/produk_detail_page.dart';
import '../notification/pages/notification_page.dart';
import '../../../providers/auth_provider.dart'; // <-- 4. TAMBAHKAN IMPORT
import '../../../providers/notification_provider.dart'; // <-- 5. TAMBAHKAN IMPORT
import '../../../providers/marketplace_provider.dart'; // <-- 6. TAMBAHKAN IMPORT

class DashboardContentPage extends StatelessWidget {
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
    // 7. HAPUS DUMMY USER
    // final UserModel user = UserModel.simulatedApiUser;
    // 8. AMBIL USER ASLI DARI AUTHPROVIDER
    final UserModel? user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: KARTU PUTIH STATIS (Welcome) ---
            _buildWelcomeCard(context, user), // <-- Kirim user asli

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
                    onTapAction: onSeeAllTapped,
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  _buildRecommendedGrid(context), // <-- Panggil versi baru
                  const SizedBox(height: 24),

                  // Bagian "Order Again"
                  _buildSectionHeader(
                    context,
                    title: 'Order Again',
                    actionText: 'Show All',
                    onTapAction:
                        null, // TODO: Navigasi ke Halaman History
                  ),
                  const SizedBox(height: 16),
                  _buildOrderAgainList(context), // <-- Panggil versi baru
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
  // 9. Ubah parameter untuk menerima UserModel nullable
  Widget _buildWelcomeCard(BuildContext context, UserModel? user) {
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
                // 10. Gunakan data user asli (dengan fallback)
                'Welcome, ${user?.name ?? 'Warga'}',
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
          Row(
            children: [
              _buildNotificationButton(context), // Tombol Notifikasi
              const SizedBox(width: 12),
              // 11. HAPUS DUMMY IMAGE AVATAR
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                // backgroundImage: NetworkImage('https://picsum.photos/200/200'),
                // Ganti dengan Icon jika tidak ada foto profil
                child: const Icon(Icons.person, color: kPrimaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET TOMBOL NOTIFIKASI ---
  Widget _buildNotificationButton(BuildContext context) {
    // 12. GUNAKAN CONSUMER UNTUK COUNT NOTIFIKASI
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        // Asumsi: Provider punya List<NotificationModel> 'notifications'
        final int notificationCount = provider.notifications.length;

        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                color: Colors.grey[700],
                size: 28,
              ),
              // 13. Tampilkan badge HANYA JIKA ada notifikasi
              if (notificationCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      // 14. HAPUS DUMMY "4"
                      notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            );
          },
        );
      },
    );
  }

  // --- WIDGET KARTU 2 (Analytics - Tidak ada data dummy) ---
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

  // (Widget helper _buildAnalyticsItem tidak berubah)
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

  // (Widget helper _buildBannerSection, _buildBannerIndicator, _buildSectionHeader, _buildFilterChips, _buildChip tidak berubah)
  // ... (Kode widget helper ini sama seperti di file asli Anda) ...
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

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String actionText,
    VoidCallback? onTapAction,
  }) {
    Widget actionWidget;
    if (onTapAction != null) {
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
          actionWidget,
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildChip('All', isSelected: true),
          // Anda bisa menambahkan chip lain di sini
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
  // --- Akhir dari widget helper yang tidak berubah ---


  // 15. PERBAIKI _buildRecommendedGrid
  Widget _buildRecommendedGrid(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        // Ambil 4 produk pertama dari provider
        final productsToShow = provider.products.take(4).toList();

        if (productsToShow.isEmpty) {
          // Tidak perlu tampilkan apa-apa jika tidak ada produk
          return const SizedBox.shrink(); 
        }

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
      },
    );
  }

  // 16. PERBAIKI _buildOrderAgainList
  Widget _buildOrderAgainList(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        // Asumsi: "Order Again" adalah 2 transaksi terakhir
        final transactionsToShow = provider.transactions.take(2).toList();

        if (transactionsToShow.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada riwayat pesanan.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          // Gunakan ListView.builder
          child: ListView.separated(
            itemCount: transactionsToShow.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              // 17. KIRIM TransaksiModel ke _buildOrderAgainCard
              return _buildOrderAgainCard(transactionsToShow[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
        );
      },
    );
  }

  // 18. UBAH PARAMETER _buildOrderAgainCard
  Widget _buildOrderAgainCard(TransaksiModel transaction) {
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
                  // 19. Gunakan gambar dari TransaksiModel
                  image: DecorationImage(
                    image: NetworkImage(transaction.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 20. Gunakan data dari TransaksiModel
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${transaction.weight} (${transaction.date})', // <-- Data dinamis
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${transaction.price}', // <-- Data dinamis
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
                onPressed: () {
                  // TODO: Navigasi ke Halaman Rating
                },
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
                onPressed: () {
                  // TODO: Logika Beli Lagi
                },
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