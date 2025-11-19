// lib/modules/marketplace/page/produk_cart_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. TAMBAHKAN IMPORT
import '../../../models/produk_model.dart';
import '../../../models/user_model.dart'; // <-- 2. TAMBAHKAN IMPORT
import '../../../providers/marketplace_provider.dart'; // <-- 3. TAMBAHKAN IMPORT
import '../../../providers/auth_provider.dart'; // <-- 4. TAMBAHKAN IMPORT

// Warna utama dari gambar
const Color kPrimaryColor = Color(0xFF1E605A);
// Definisikan warna latar belakang body
const Color kAppBackgroundColor = Color(0xFFF7F7F7);

/// ==============================
/// SCREEN 1: My Cart (Keranjang Saya)
/// ==============================
class CartScreen extends StatelessWidget {
  // 5. HAPUS 'cartItems' DARI CONSTRUCTOR
  const CartScreen({super.key});

  // 6. PINDAHKAN LOGIKA INI KE DALAM BUILD METHOD ATAU PROVIDER
  // (Kita akan buat ulang di dalam Consumer)

  @override
  Widget build(BuildContext context) {
    // 7. GUNAKAN CONSUMER UNTUK MENDAPATKAN DATA KERANJANG
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        // Ambil data dari provider
        final List<ProdukModel> cartItems = provider.cartItems;

        // --- Logika yang dipindahkan ---
        final int totalCost =
            cartItems.fold(0, (sum, item) => sum + item.price);
        String formattedTotalCost;
        if (cartItems.isEmpty) {
          formattedTotalCost = 'Rp. 0,-';
        } else {
          final s = totalCost.toString();
          final buffer = StringBuffer();
          int count = 0;
          for (int i = s.length - 1; i >= 0; i--) {
            buffer.write(s[i]);
            count++;
            if (count == 3 && i != 0) {
              buffer.write('.');
              count = 0;
            }
          }
          formattedTotalCost =
              'Rp. ${buffer.toString().split('').reversed.join()},-';
        }
        // --- Akhir logika ---

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: kPrimaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Keranjang Saya (${cartItems.length})', // <-- Gunakan data provider
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // 8. TAMBAHKAN KONDISI JIKA KERANJANG KOSONG
          body: cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Keranjang Anda masih kosong.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: cartItems.length, // <-- Gunakan data provider
                      itemBuilder: (context, index) {
                        final item = cartItems[index]; // <-- Gunakan data provider
                        return CartItem(
                          produk: item,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                          indent: 16,
                          endIndent: 16,
                        );
                      },
                      // Hapus shrinkWrap dan physics, biarkan ListView scrollable
                    ),
                  ),
                ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total :',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text(
                          formattedTotalCost, // <-- Gunakan data provider
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      // 9. Nonaktifkan tombol jika keranjang kosong
                      onPressed: cartItems.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutScreen(
                                    totalCost: formattedTotalCost,
                                    cartItems: cartItems, // <-- Gunakan data provider
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Pay Now',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ==============================
/// WIDGET: Cart Item
/// ==============================
class CartItem extends StatelessWidget {
  final ProdukModel produk;
  // 10. HAPUS PLACEHOLDER (logika kuantitas harus ditangani provider)
  // final int quantity = 1;

  const CartItem({
    required this.produk,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 11. AMBIL KUANTITAS DARI PROVIDER
    final quantity =
        Provider.of<MarketplaceProvider>(context).getQuantity(produk);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              produk.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      produk.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    // 12. Tombol Hapus (dari provider)
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: Colors.grey[400]),
                      onPressed: () {
                        Provider.of<MarketplaceProvider>(context, listen: false)
                            .removeFromCart(produk);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Fresh Banana India\n0,5 kg (Pcs)', // Ini placeholder UI
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      produk.formattedPrice,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    // 13. Hubungkan tombol kuantitas ke provider
                    _buildQuantitySelector(context, produk, quantity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 14. Modifikasi _buildQuantitySelector
  Widget _buildQuantitySelector(
      BuildContext context, ProdukModel produk, int quantity) {
    final provider = Provider.of<MarketplaceProvider>(context, listen: false);

    return Row(
      children: [
        _buildQuantityButton(Icons.remove, onPressed: () {
          provider.decrementQuantity(produk); // <-- Panggil provider
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(quantity.toString(), // <-- Gunakan data provider
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        _buildQuantityButton(Icons.add, isAdd: true, onPressed: () {
          provider.incrementQuantity(produk); // <-- Panggil provider
        }),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon,
      {bool isAdd = false, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isAdd ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isAdd ? kPrimaryColor : Colors.grey[300]!),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isAdd ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }
}

/// ==============================
/// SCREEN 2: Checkout (Halaman Utama)
/// ==============================
class CheckoutScreen extends StatefulWidget {
  final String totalCost;
  final List<ProdukModel> cartItems;

  const CheckoutScreen({
    required this.totalCost,
    required this.cartItems,
    super.key,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor, // AppBar tetap hijau
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAddressCard(context), // <-- Kirim context
            _buildPaymentCard(),
            _buildItemsCard(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrderAcceptedScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(
                    vertical: 16), // Padding internal tombol
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Place Order',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  // Card Alamat
  Widget _buildAddressCard(BuildContext context) {
    // 15. AMBIL DATA USER DARI AUTHPROVIDER
    final UserModel? user = Provider.of<AuthProvider>(context).user;
    // Format alamat (jika ada)
    final String address = user?.address ?? 'Alamat belum diatur.';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white, // Kartu putih
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person_pin_circle_outlined,
                        color: kPrimaryColor),
                    SizedBox(width: 8),
                    Text('Address',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddressFormPage()));
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
            // 16. HAPUS ALAMAT DUMMY DAN GANTI DENGAN DATA PROVIDER
            Text(
              address,
              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // Card Metode Pembayaran (Tidak berubah, sudah OK)
  Widget _buildPaymentCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment_outlined, color: kPrimaryColor),
                    SizedBox(width: 8),
                    Text('Payment Methods',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12),
                Text('QRIS',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            Radio<String>(
              value: 'QRIS',
              groupValue: _selectedPaymentMethod,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                }
              },
              activeColor: kPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }

  // Card Rangkuman Item (Tidak berubah, sudah OK)
  Widget _buildItemsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ...widget.cartItems.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          const Text('0,5 Kg (Pcs)',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const Text('1x',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Payment',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(widget.totalCost,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ==============================
/// SCREEN 3: Address Form Page (Tidak ada data dummy)
/// ==============================
class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  // Controllers untuk form
  final _alamatController = TextEditingController();
  final _rtRwController = TextEditingController();
  final _kelurahanController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kotaController = TextEditingController();
  final _kodePosController = TextEditingController();
  final _noHpController = TextEditingController();

  // 17. AMBIL DATA USER SAAT INIT (Untuk mengisi form)
  @override
  void initState() {
    super.initState();
    final UserModel? user =
        Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _alamatController.text = user.address;
      _noHpController.text = user.mobileNumber;
      // TODO: Anda perlu mem-parsing 'alamat' untuk mengisi field lain
      // (misal _rtRwController, _kelurahanController, dll)
      // Ini adalah contoh sederhana:
    }
  }

  @override
  void dispose() {
    _alamatController.dispose();
    _rtRwController.dispose();
    _kelurahanController.dispose();
    _kecamatanController.dispose();
    _kotaController.dispose();
    _kodePosController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor, // AppBar tetap hijau
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Address', // Judul diubah
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white, // Kartu tetap putih
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person_pin_circle_outlined,
                        color: kPrimaryColor),
                    SizedBox(width: 8),
                    Text('Address',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(_alamatController, 'Alamat'),
                const SizedBox(height: 16),
                _buildTextField(_rtRwController, 'Rt/Rw'),
                const SizedBox(height: 16),
                _buildTextField(_kelurahanController, 'Kelurahan'),
                const SizedBox(height: 16),
                _buildTextField(_kecamatanController, 'Kecamatan'),
                const SizedBox(height: 16),
                _buildTextField(_kotaController, 'Kota'),
                const SizedBox(height: 16),
                _buildTextField(_kodePosController, 'Kode Pos',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField(_noHpController, 'No. Handphone',
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Logika simpan alamat (kirim ke AuthProvider/API)
                      Navigator.pop(context); // Kembali ke halaman checkout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk text field
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryColor),
        ),
      ),
    );
  }
}

/// ==============================
/// SCREEN 4: Order Accepted (Tidak ada data dummy)
/// ==============================
class OrderAcceptedScreen extends StatelessWidget {
  const OrderAcceptedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFF7F7F7),
            ], // Latar putih gading
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Lingkaran Ceklis (Sudah sesuai)
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimaryColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimaryColor,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 90),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Teks (Sudah sesuai)
              const Text(
                'Your Order has been\naccepted',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.0),
                child: Text(
                  "Your items has been placed and is on it's way to being processed",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const Spacer(),
              // Tombol (Sudah sesuai)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigasi ke halaman Lacak Pesanan
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Track Order',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  'Back to home',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}