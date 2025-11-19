// lib/modules/marketplace/pages/product_form_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/produk_model.dart';
import '../../providers/marketplace_provider.dart';

class ProductFormPage extends StatefulWidget {
  final ProdukModel? produk;

  const ProductFormPage({super.key, this.produk});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;
  
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  // --- STYLE CONSTANTS (Sesuai Request Warna) ---
  static const Color primaryGreen = Color(0xFF2D7F6A); // Warna Utama
  static const Color secondaryGreen = Color(0xFF1E5A4A); // Warna Teks Aksen
  static const Color bgInput = Color.fromRGBO(45, 127, 106, 0.08); // Background Input Halus
  static const Color borderInput = Color.fromRGBO(0, 0, 0, 0.1); // Border Tipis

  // Gaya Teks Label
  TextStyle get labelStyle => const TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Color(0xFF333333),
  );

  // Gaya Teks Hint/Placeholder
  TextStyle get hintStyle => TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: Colors.grey[500],
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.produk?.namaProduk ?? '');
    _descController = TextEditingController(text: widget.produk?.deskripsi ?? '');
    _priceController = TextEditingController(text: widget.produk?.harga.toString() ?? '');
    _stockController = TextEditingController(text: widget.produk?.stok.toString() ?? '');
    _categoryController = TextEditingController(text: widget.produk?.kategori ?? '');
  }

  // --- LOGIC ---
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Wrap(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library, color: primaryGreen),
                ),
                title: const Text('Ambil dari Galeri', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                onTap: () { Navigator.pop(context); _processImage(ImageSource.gallery); },
              ),
              ListTile(
                leading: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                   child: const Icon(Icons.camera_alt, color: primaryGreen),
                ),
                title: const Text('Ambil Foto', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                onTap: () { Navigator.pop(context); _processImage(ImageSource.camera); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) setState(() => _selectedImagePath = picked.path);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kategori wajib diisi")));
        return;
    }

    final provider = Provider.of<MarketplaceProvider>(context, listen: false);
    final isEdit = widget.produk != null;
    bool success;

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: primaryGreen)));

    try {
      if (isEdit) {
        success = await provider.updateProduct(
          id: widget.produk!.id,
          nama: _nameController.text,
          deskripsi: _descController.text,
          harga: int.tryParse(_priceController.text) ?? 0,
          stok: int.tryParse(_stockController.text) ?? 0,
          kategori: _categoryController.text,
          imagePath: _selectedImagePath,
        );
      } else {
        if (_selectedImagePath == null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wajib upload foto produk")));
          return;
        }
        success = await provider.addProduct(
          nama: _nameController.text,
          deskripsi: _descController.text,
          harga: int.tryParse(_priceController.text) ?? 0,
          stok: int.tryParse(_stockController.text) ?? 0,
          kategori: _categoryController.text,
          imagePath: _selectedImagePath!,
        );
      }

      if (mounted) Navigator.pop(context);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit ? "Produk Diupdate" : "Produk Ditambah"),
          backgroundColor: primaryGreen,
        ));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // HEADER HIJAU
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.produk != null ? "Edit Product" : "Tambah Product",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. KOTAK FOTO PRODUK
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderInput, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Foto Produk", style: labelStyle),
                        const Text("Foto 1:1", style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: secondaryGreen, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryGreen, width: 1.5), // Solid border rapi
                          boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
                        ),
                        child: _selectedImagePath != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(_selectedImagePath!), fit: BoxFit.cover))
                            : (widget.produk != null 
                                ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(widget.produk!.imageUrl, fit: BoxFit.cover))
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_a_photo_outlined, color: primaryGreen, size: 28),
                                      SizedBox(height: 6),
                                      Text("Tambah\nFoto", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: primaryGreen, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                                    ],
                                  )),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. NAMA PRODUK
              _buildInputContainer(
                label: "Nama Produk",
                counter: "0/255",
                child: TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: "Masukkan Nama Produk",
                    hintStyle: hintStyle,
                    contentPadding: const EdgeInsets.only(bottom: 8),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
              ),
              const SizedBox(height: 16),

              // 3. KATEGORI
              _buildInputContainer(
                label: "Kategori",
                counter: "",
                child: TextFormField(
                  controller: _categoryController,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: "Contoh: Sayuran, Buah, Olahan",
                    hintStyle: hintStyle,
                    contentPadding: const EdgeInsets.only(bottom: 8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. DESKRIPSI
              _buildInputContainer(
                label: "Deskripsi Produk",
                counter: "0/3000",
                child: TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: "Jelaskan detail produkmu di sini...",
                    hintStyle: hintStyle,
                    contentPadding: const EdgeInsets.only(bottom: 8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. DETAIL GROUP (Harga & Stok)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderInput, width: 1),
                ),
                child: Column(
                  children: [
                    _buildDetailRow("Harga Produk", _priceController, "Atur", isCurrency: true),
                    const Divider(color: Color(0xFFE2E2E2), thickness: 1),
                    _buildDetailRow("Stok Produk", _stockController, "Pcs/Kg", isNumber: true),
                    const Divider(color: Color(0xFFE2E2E2), thickness: 1),
                    _buildDetailRow("Min. Pembelian", TextEditingController(text: "1"), "Pcs", isReadOnly: true),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 6. TOMBOL SIMPAN (Full Width)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 3,
                    shadowColor: primaryGreen.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "Simpan Produk",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 0.5
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk kotak input standar (Nama, Deskripsi)
  Widget _buildInputContainer({required String label, required String counter, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderInput, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: labelStyle),
              if(counter.isNotEmpty)
                Text(counter, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: secondaryGreen, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8), // Jarak label ke input
          child,
        ],
      ),
    );
  }

  // Widget untuk baris detail (Harga, Stok)
  Widget _buildDetailRow(String label, TextEditingController ctrl, String placeholder, {bool isNumber = false, bool isReadOnly = false, bool isCurrency = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCurrency && ctrl.text.isNotEmpty) 
                  const Text("Rp ", style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: primaryGreen)),
                Expanded(
                  child: TextFormField(
                    controller: ctrl,
                    readOnly: isReadOnly,
                    textAlign: TextAlign.end,
                    keyboardType: isNumber || isCurrency ? TextInputType.number : TextInputType.text,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: placeholder,
                      hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}