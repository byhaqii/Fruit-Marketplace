import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Models
import '../../../models/user_model.dart';
import '../../../models/transaksi_model.dart';
import '../../../models/produk_model.dart';

// Providers
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/marketplace_provider.dart';

// Pages
import '../marketplace/pages/produk_detail_page.dart';
import '../notification/pages/notification_page.dart';
import '../marketplace/widgets/produk_card.dart'; // Pastikan widget ini ada

class DashboardContentPage extends StatefulWidget {
  final VoidCallback onSeeAllTapped;

  const DashboardContentPage({
    super.key,
    required this.onSeeAllTapped,
  });

  @override
  State<DashboardContentPage> createState() => _DashboardContentPageState();
}

class _DashboardContentPageState extends State<DashboardContentPage> {
  // Warna desain
  static const Color kPrimaryColor = Color(0xFF1E605A);
  static const Color kAnalyticsCardColor1 = Color(0xFF4C8A82);
  static const Color kAnalyticsCardColor2 = Color(0xFF1E7B70);
  static const Color kChipSelectedColor = Color(0xFFFFFFFF);
  static const Color kChipUnselectedColor = Color(0xFF4C8A82);
  static const Color kBannerImageBackground = Color(0xFFF3F3F3);

  @override
  void initState() {
    super.initState();
    // Refresh data produk dan transaksi saat halaman ini dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
      marketplaceProvider.fetchProducts(); // Ambil data produk terbaru
      marketplaceProvider.fetchTransactions(); // Ambil history transaksi untuk "Order Again"
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Ambil data User Asli
    final UserModel? user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Welcome Card)
            _buildWelcomeCard(context, user),

            // Konten Scrollable
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Bagian Analytics (Statistik User - Opsional)
                  _buildAnalyticsCard(),

                  // Konten Utama
                  const SizedBox(height: 24),
                  _buildBannerSection(),
                  const SizedBox(height: 12),
                  _buildBannerIndicator(),
                  const SizedBox(height: 24),

                  // Bagian Recommended Products
                  _buildSectionHeader(
                    context,
                    title: 'Recommended',
                    actionText: 'See All',
                    onTapAction: widget.onSeeAllTapped,
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  _buildRecommendedGrid(context), // <-- Grid Produk Asli
                  const SizedBox(height: 24),

                  // Bagian Order Again (History)
                  _buildSectionHeader(
                    context,
                    title: 'Order Again',
                    actionText: 'Show All',
                    onTapAction: widget.onSeeAllTapped, // Arahkan ke tab history jika mau
                  ),
                  const SizedBox(height: 16),
                  _buildOrderAgainList(context), // <-- List Transaksi Asli
                  const SizedBox(height: 90), // Spacer bawah agar tidak tertutup nav bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

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
                'Welcome, ${user?.name ?? 'Pembeli'}',
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMMM', 'id_ID').format(DateTime.now()),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              _buildNotificationButton(context),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, color: kPrimaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final int count = provider.notifications.length;
        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined, color: Colors.grey[700], size: 28),
              if (count > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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

  Widget _buildAnalyticsCard() {
    // Kartu ini bisa diisi data point loyalty atau saldo di masa depan
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
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Activity',
                style: TextStyle(color: kPrimaryColor, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnalyticsItem('Vouchers', kAnalyticsCardColor1),
              _buildAnalyticsItem('Points', kAnalyticsCardColor1),
              _buildAnalyticsItem('Gift Cards', kAnalyticsCardColor2),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(String title, Color color) {
    return Container(
      width: 105,
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  // --- GRID PRODUK ASLI ---
  Widget _buildRecommendedGrid(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        
        // Ambil maksimal 4 produk untuk ditampilkan di Dashboard
        final products = provider.products.take(4).toList();

        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Belum ada produk tersedia", style: TextStyle(color: Colors.white)),
          );
        }

        return GridView.builder(
          itemCount: products.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7, // Sesuaikan rasio kartu produk
          ),
          itemBuilder: (context, index) {
            // Gunakan widget ProdukCard yang sudah Anda miliki (atau buat baru)
            // Asumsi ProdukCard menerima parameter 'produk'
            return ProdukCard(
              produk: products[index],
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProdukDetailPage(produk: products[index]),
                  ),
                );
              }
            );
          },
        );
      },
    );
  }

  // --- LIST ORDER AGAIN (TRANSAKSI TERAKHIR) ---
  Widget _buildOrderAgainList(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        // Ambil 2 transaksi terakhir
        final transactions = provider.transactions.take(2).toList();

        if (transactions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Belum ada riwayat pesanan", style: TextStyle(color: Colors.white70)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: transactions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildOrderAgainCard(transactions[index]);
          },
        );
      },
    );
  }

  Widget _buildOrderAgainCard(TransaksiModel transaction) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
              image: DecorationImage(
                image: NetworkImage(transaction.imageUrl),
                fit: BoxFit.cover,
                onError: (e, s) {},
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${transaction.date} • ${transaction.status}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  transaction.price,
                  style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Banner & Header Helpers (Sama seperti sebelumnya) ---
  
  Widget _buildBannerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
             // Ganti dengan asset lokal atau network image banner Anda
             image: AssetImage('assets/fruit_background.jpg'), 
             fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.black45,
          child: const Text(
            "Diskon Spesial Hari Ini!",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == 0 ? Colors.white : Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required String actionText, required VoidCallback onTapAction}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: onTapAction,
            child: Text(
              actionText,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
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
          _buildChip('Fruits', isSelected: false),
          _buildChip('Vegetables', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? kChipSelectedColor : kChipUnselectedColor,
        labelStyle: TextStyle(
          color: isSelected ? kPrimaryColor : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
      ),
    );
  }
}