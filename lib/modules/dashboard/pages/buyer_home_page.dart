// lib/modules/dashboard/pages/buyer_home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/marketplace_provider.dart';
import '../widgets/discount_card.dart';
import '../../marketplace/widgets/produk_card.dart';
import '../../../config/env.dart';
import '../../marketplace/pages/produk_detail_page.dart'; 

class BuyerHomePage extends StatefulWidget {
  final VoidCallback? onGoToShop; 

  const BuyerHomePage({
    super.key, 
    this.onGoToShop, 
  });

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  // Pastikan nama kategori ini SAMA dengan data 'kategori' di database/seeder Anda
  final List<String> categories = ["Semua", "Apel", "Jeruk Bali", "Peach", "Tomat"];
  
  int selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // --- Helper URL ---
  String _getStorageBaseUrl() {
    return Env.apiBaseUrl.replaceFirst('/api', '');
  }

  String getAvatarUrl(String? filename) {
    if (filename == null || filename.isEmpty) return ''; 
    return '${_getStorageBaseUrl()}/storage/profiles/$filename';
  }
  // -----------------------

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MarketplaceProvider>(context, listen: false).fetchAllData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final String displayName = (user?.name != null && user!.name.isNotEmpty) 
        ? user.name 
        : "Pelanggan";
    
    const Color mainBackgroundColor = Color(0xFF2D7F6A);
    
    final String? avatarFilename = user?.avatar;
    final bool hasAvatar = avatarFilename != null && avatarFilename.isNotEmpty;
    final ImageProvider? avatarImage = hasAvatar 
        ? NetworkImage(getAvatarUrl(avatarFilename!)) 
        : null;


    return Scaffold(
      backgroundColor: mainBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: mainBackgroundColor,
          backgroundColor: Colors.white,
          onRefresh: () async {
            await Provider.of<MarketplaceProvider>(context, listen: false).fetchAllData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Halo, $displayName 👋", style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          const Text("Cari Kebutuhanmu?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
                        child: CircleAvatar(
                            radius: 24, 
                            backgroundColor: Colors.white.withOpacity(0.2), 
                            backgroundImage: avatarImage, 
                            child: hasAvatar 
                                ? null 
                                : const Icon(Icons.person, color: Colors.white), 
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. SEARCH BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        widget.onGoToShop?.call();
                      },
                      decoration: const InputDecoration(
                        hintText: "Cari produk...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 3. DISCOUNT CARD
                Center(
                  child: DiscountCard(
                    onPressed: widget.onGoToShop,
                  ),
                ),

                // 4. ORDER AGAIN (BELI LAGI)
                 Consumer<MarketplaceProvider>(
                  builder: (context, provider, _) {
                    if (provider.buyAgainList.isEmpty) return const SizedBox.shrink();
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: const [
                              Icon(Icons.history, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text("Beli Lagi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 120, 
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: provider.buyAgainList.length,
                            itemBuilder: (context, index) {
                              final produk = provider.buyAgainList[index];
                              return Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 15),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProdukDetailPage(produk: produk),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.network(
                                          produk.imageUrl, 
                                          height: 70, 
                                          width: double.infinity, 
                                          fit: BoxFit.cover, 
                                          errorBuilder: (ctx,_,__) => Container(height: 70, color: Colors.grey[300])
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(produk.namaProduk, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                            Text(produk.formattedPrice, style: const TextStyle(fontSize: 9, color: Color(0xFF2D7F6A))),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 25),

                // 5. KATEGORI & LIHAT SEMUA (DIGABUNG DALAM SATU ROW)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Kategori", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      // Tombol Lihat Semua dipindah ke sini
                      TextButton(
                        onPressed: widget.onGoToShop,
                        child: const Text("Lihat Semua", style: TextStyle(color: Colors.white70)),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // FILTER CHIPS KATEGORI
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final bool isSelected = selectedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategoryIndex = index), // Update state saat diklik
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected ? null : Border.all(color: Colors.white38),
                          ),
                          child: Center(
                            child: Text(
                              categories[index],
                              style: TextStyle(color: isSelected ? mainBackgroundColor : Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // 6. GRID PRODUK (LOGIKA FILTER DIPERBAIKI)
                Consumer<MarketplaceProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50.0), 
                          child: CircularProgressIndicator(color: Colors.white)
                        )
                      );
                    }
                    
                    // --- PERBAIKAN LOGIKA FILTER ---
                    final allProducts = provider.products;
                    final selectedCategory = categories[selectedCategoryIndex];
                    
                    final filteredProducts = selectedCategory == "Semua"
                        ? allProducts
                        : allProducts.where((p) {
                            final filterKeyword = selectedCategory.toLowerCase();
                            final productCategory = p.kategori.toLowerCase();
                            final productName = p.namaProduk.toLowerCase();
                            
                            // Cek: Apakah Kategori ATAU Nama Produk mengandung kata kunci?
                            // Contoh: Jika klik "Apel", maka produk dengan nama "Apel Malang" akan muncul
                            return productCategory.contains(filterKeyword) || 
                                   productName.contains(filterKeyword);
                          }).toList();
                    // -------------------------------------

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0), 
                          child: Text(
                            "Produk '$selectedCategory' tidak ditemukan.", 
                            style: const TextStyle(color: Colors.white)
                          )
                        )
                      );
                    }
                    
                    // Batasi tampilan hanya 4 item di Home
                    final displayProducts = filteredProducts.take(4).toList();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.70,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemBuilder: (context, index) {
                          final produk = displayProducts[index];
                          return ProdukCard(
                            produk: produk, 
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProdukDetailPage(produk: produk),
                                ),
                              );
                            }
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}