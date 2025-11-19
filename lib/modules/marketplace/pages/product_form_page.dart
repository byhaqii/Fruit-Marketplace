// lib/modules/marketplace/pages/product_form_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // 1. Import Image Picker
import '../../../models/produk_model.dart';
import '../../../providers/marketplace_provider.dart';

class ProductFormPage extends StatefulWidget {
  final ProdukModel? produk; // Jika null = Tambah, Jika ada = Edit

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
  
  String? _selectedImagePath; // Menyimpan path gambar dari HP
  final ImagePicker _picker = ImagePicker(); // Instance Image Picker

  @override
  void initState() {
    super.initState();
    // Isi controller (kosong jika tambah, terisi jika edit)
    _nameController = TextEditingController(text: widget.produk?.namaProduk ?? '');
    _descController = TextEditingController(text: widget.produk?.deskripsi ?? '');
    _priceController = TextEditingController(text: widget.produk?.harga.toString() ?? '');
    _stockController = TextEditingController(text: widget.produk?.stok.toString() ?? '');
    _categoryController = TextEditingController(text: widget.produk?.kategori ?? '');
  }

  // --- FUNGSI AMBIL GAMBAR ---
  Future<void> _pickImage() async {
    // Tampilkan Modal Bawah untuk pilih Galeri / Kamera
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Ambil dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  _processImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () async {
                  Navigator.pop(context);
                  _processImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Kompresi gambar biar tidak terlalu besar
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengambil gambar")),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<MarketplaceProvider>(context, listen: false);
    final isEdit = widget.produk != null;
    bool success;

    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.teal))
    );

    if (isEdit) {
      success = await provider.updateProduct(
        id: widget.produk!.id,
        nama: _nameController.text,
        deskripsi: _descController.text,
        harga: int.parse(_priceController.text),
        stok: int.parse(_stockController.text),
        kategori: _categoryController.text,
        imagePath: _selectedImagePath, // Kirim path gambar baru (jika ada)
      );
    } else {
      // Validasi Gambar Wajib untuk Produk Baru
      if (_selectedImagePath == null) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wajib pilih gambar untuk produk baru"))
        );
        return;
      }

      success = await provider.addProduct(
        nama: _nameController.text,
        deskripsi: _descController.text,
        harga: int.parse(_priceController.text),
        stok: int.parse(_stockController.text),
        kategori: _categoryController.text,
        imagePath: _selectedImagePath!,
      );
    }

    if (mounted) Navigator.pop(context); // Tutup Loading

    if (success && mounted) {
      Navigator.pop(context); // Kembali ke list produk
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? "Produk Diupdate" : "Produk Ditambah"))
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan produk. Cek koneksi."))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.produk != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Produk" : "Tambah Produk"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- AREA UPLOAD GAMBAR ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _buildImagePreview(isEdit),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tap kotak di atas untuk upload foto",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),

              // --- FORM INPUT ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Produk", 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag_outlined)
                ),
                validator: (v) => v!.isEmpty ? "Nama produk wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: "Kategori (Cth: Buah, Sayur)", 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined)
                ),
                validator: (v) => v!.isEmpty ? "Kategori wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Harga (Rp)", 
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money)
                      ),
                      validator: (v) => v!.isEmpty ? "Isi harga" : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Stok", 
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2_outlined)
                      ),
                      validator: (v) => v!.isEmpty ? "Isi stok" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Produk", 
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? "Deskripsi wajib diisi" : null,
              ),
              const SizedBox(height: 30),

              // --- TOMBOL SIMPAN ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    isEdit ? "UPDATE PRODUK" : "SIMPAN PRODUK", 
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(bool isEdit) {
    // 1. Jika User baru saja memilih foto dari galeri -> Tampilkan File Lokal
    if (_selectedImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(_selectedImagePath!), fit: BoxFit.cover),
      );
    }
    
    // 2. Jika Edit Mode & belum ganti foto -> Tampilkan Foto dari Internet
    if (isEdit && widget.produk != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.produk!.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
        ),
      );
    }

    // 3. Tampilan Default (Kosong)
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 40, color: Colors.teal),
        SizedBox(height: 8),
        Text("Tambah Foto", style: TextStyle(color: Colors.teal)),
      ],
    );
  }
}