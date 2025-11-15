// lib/modules/marketplace/page/produk_cart_page.dart
import 'package:flutter/material.dart';
import '../../../models/produk_model.dart';
// Untuk efek blur di OrderAcceptedScreen

// Warna utama dari gambar
const Color kPrimaryColor = Color(0xFF1E605A);
// Definisikan warna latar belakang body
const Color kAppBackgroundColor = Color(0xFFF7F7F7);

/// ==============================
/// SCREEN 1: My Cart (Keranjang Saya)
/// ==============================
class CartScreen extends StatelessWidget {
  final List<ProdukModel> cartItems;

  const CartScreen({required this.cartItems, super.key});

  // Hitung total harga
  int get totalCost => cartItems.fold(0, (sum, item) => sum + item.price);

  // Format total harga
  String get formattedTotalCost {
    if (cartItems.isEmpty) return 'Rp. 0,-';
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
    return 'Rp. ${buffer.toString().split('').reversed.join()},-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar body putih (Sesuai Gambar 1)
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
              'Keranjang Saya (${cartItems.length})',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding di luar kartu
        child: Container(
          // Ini adalah SATU KARTU UTAMA
          decoration: BoxDecoration(
            color: const Color(0xFFF5F9F9), // Warna dari screenshot
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero, // Hapus padding default ListView
            shrinkWrap: true, // Penting untuk membatasi tinggi ListView
            physics:
                const NeverScrollableScrollPhysics(), // Menonaktifkan scroll ListView ini
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return CartItem(
                produk: item,
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200], // Garis pemisah abu-abu muda
                indent: 16, // Beri jarak di kiri
                endIndent: 16, // Beri jarak di kanan
              );
            },
          ),
        ),
      ),

      // --- PERBAIKAN BOTTOM OVERFLOW (CartScreen) ---
      // Mengganti BottomAppBar dengan Container untuk kontrol penuh
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
        // 1. Padding untuk Safe Area (lekukan bawah layar)
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          // 2. Padding untuk konten di dalamnya
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
                      formattedTotalCost,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          totalCost: formattedTotalCost,
                          cartItems: cartItems,
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
      // --- AKHIR PERBAIKAN ---
    );
  }
}

/// ==============================
/// WIDGET: Cart Item
/// ==============================
class CartItem extends StatelessWidget {
  final ProdukModel produk;
  final int quantity = 1; // Placeholder, idealnya dari state

  const CartItem({
    required this.produk,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // Gambar
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
          // Detail Item
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
                    Icon(Icons.close, size: 20, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Fresh Banana India\n0,5 kg (Pcs)',
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
                    _buildQuantitySelector(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk tombol +/-
  Widget _buildQuantitySelector() {
    return Row(
      children: [
        _buildQuantityButton(Icons.remove, onPressed: () {
          // TODO: Logika mengurangi qty
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(quantity.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        _buildQuantityButton(Icons.add, isAdd: true, onPressed: () {
          // TODO: Logika menambah qty
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
  // --- PERUBAHAN DI SINI ---
  // Ubah nilai awal menjadi null agar tidak ada yang terpilih.
  // Tipe datanya diubah menjadi String? (nullable).
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
            // Kartu-kartu konten
            _buildAddressCard(context),
            _buildPaymentCard(), // Sekarang memanggil method di dalam State
            _buildItemsCard(), // Sekarang memanggil method di dalam State
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
            const Text(
              'Jl. Soekarno Hatta No.9\nRt 44/ Rw 10\nKel. Jatimulyo\nKec. Lowokwaru\nKOTA MALANG\nJAWA TIMUR\n65141\n081336347990',
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // Card Metode Pembayaran
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
              value: 'QRIS', // Nilai untuk tombol ini adalah 'QRIS'
              groupValue:
                  _selectedPaymentMethod, // Nilai grup diambil dari state (null)
              onChanged: (String? value) {
                // Saat ditekan, perbarui state
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

  // Card Rangkuman Item
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
            // Daftar item (ambil 3 pertama)
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
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ==============================
/// SCREEN 3: Address Form Page
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
                      // TODO: Logika simpan alamat
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
/// SCREEN 4: Order Accepted
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