// lib/modules/marketplace/pages/produk_cart_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/produk_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/marketplace_provider.dart';
import '../../../providers/auth_provider.dart';

// Warna utama dari gambar
const Color kPrimaryColor = Color(0xFF1E605A);
// Definisikan warna latar belakang body
const Color kAppBackgroundColor = Color(0xFFF7F7F7);

/// ==============================
/// SCREEN 1: My Cart (Keranjang Saya)
/// ==============================
class ProdukCartPage extends StatelessWidget {
  const ProdukCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        // Ambil data cartItems dari provider
        final List<ProdukModel> cartItems = provider.cartItems;

        // Ambil total cost yang sudah diformat dari provider
        final String formattedTotalCost = provider.formattedTotalCost;

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
                  'Keranjang Saya (${provider.cartItemCount})', // Gunakan cartItemCount dari provider
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
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
                          color: Colors.grey[200],
                          indent: 16,
                          endIndent: 16,
                        );
                      },
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
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
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
                      onPressed: cartItems.isEmpty
                          ? null
                          : () {
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

  const CartItem({
    required this.produk,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketplaceProvider>(context);
    final quantity = provider.getQuantity(produk);

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
                    // PERBAIKAN: Gunakan 'namaProduk' bukan 'title'
                    Flexible(
                      child: Text(
                        produk.namaProduk,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: Colors.grey[400]),
                      onPressed: () {
                        provider.removeFromCart(produk);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  produk.kategori.isNotEmpty ? produk.kategori : 'Umum',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // PERBAIKAN: Gunakan 'formattedPrice'
                    Text(
                      produk.formattedPrice,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
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

  Widget _buildQuantitySelector(
      BuildContext context, ProdukModel produk, int quantity) {
    final provider = Provider.of<MarketplaceProvider>(context, listen: false);

    return Row(
      children: [
        _buildQuantityButton(Icons.remove, onPressed: () {
          provider.decrementQuantity(produk);
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(quantity.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        _buildQuantityButton(Icons.add, isAdd: true, onPressed: () {
          provider.incrementQuantity(produk);
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
  String? _selectedPaymentMethod = 'QRIS'; // Default payment method
  // Controller alamat
  final _alamatController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Pre-fill alamat dari user data jika ada
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if(user != null) {
        _alamatController.text = user.address;
    }
  }

  @override
  void dispose() {
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAddressCard(context),
            _buildPaymentCard(),
            _buildItemsCard(context), // Pass context to access provider
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
            child: Consumer<MarketplaceProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : () async {
                    // VALIDASI ALAMAT
                    if (_alamatController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mohon isi alamat pengiriman'))
                        );
                        return;
                    }

                    // PROSES CHECKOUT KE BACKEND
                    bool success = await provider.checkout(
                        _alamatController.text, 
                        _selectedPaymentMethod ?? 'Manual'
                    );

                    if (success && context.mounted) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OrderAcceptedScreen()));
                    } else if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Checkout Gagal, coba lagi.'))
                        );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: provider.isLoading 
                    ? const SizedBox(
                        height: 20, width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Place Order',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
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
                  onPressed: () async {
                    // Navigasi ke form edit alamat, dan tunggu hasilnya
                    final newAddress = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddressFormPage(initialAddress: _alamatController.text)));
                    
                    if (newAddress != null && newAddress is String) {
                        setState(() {
                            _alamatController.text = newAddress;
                        });
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _alamatController.text.isEmpty ? 'Alamat belum diatur' : _alamatController.text,
              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildItemsCard(BuildContext context) {
    // Ambil provider untuk mendapatkan quantity
    final provider = Provider.of<MarketplaceProvider>(context, listen: false);
    
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
            ...widget.cartItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded( // Gunakan Expanded agar text tidak overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.namaProduk, // Gunakan namaProduk
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis,),
                            Text(item.kategori.isNotEmpty ? item.kategori : 'Umum',
                                style:
                                    const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text('${provider.getQuantity(item)}x', // Ambil quantity real
                          style: const TextStyle(
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
/// SCREEN 3: Address Form Page
/// ==============================
class AddressFormPage extends StatefulWidget {
  final String? initialAddress;
  const AddressFormPage({super.key, this.initialAddress});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _alamatController = TextEditingController();
  final _rtRwController = TextEditingController();
  final _kelurahanController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kotaController = TextEditingController();
  final _kodePosController = TextEditingController();
  final _noHpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
        _alamatController.text = widget.initialAddress!;
    }
    
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
       if(_alamatController.text.isEmpty) _alamatController.text = user.address;
       _noHpController.text = user.mobileNumber;
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
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Address',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
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
                _buildTextField(_alamatController, 'Alamat Lengkap'),
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
                      // Kembalikan alamat yang sudah diisi ke halaman sebelumnya
                      Navigator.pop(context, _alamatController.text);
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFF7F7F7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                       // Reset ke dashboard
                       Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Back to Home',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
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