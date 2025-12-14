// lib/modules/Seller/product_form_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/produk_model.dart';
import '../../providers/marketplace_provider.dart';

const Color primaryGreen = Color(0xFF2D7F6A);
const Color secondaryGreen = Color(0xFF4BAE8C);
const Color bgInput = Color(0xFFF8F8F8);
const Color borderInput = Color(0xFFE2E2E2);

const TextStyle labelStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Colors.black87,
);

const TextStyle hintStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  color: Colors.grey,
);

class ProductFormPage extends StatefulWidget {
  final ProdukModel? produk;

  const ProductFormPage({Key? key, this.produk}) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minPurchaseController = TextEditingController(text: '1');

  final ImagePicker _picker = ImagePicker();
  List<String> _selectedImages = [];
  bool _isSubmitting = false;
  static const int _nameMax = 60;
  static const int _descMax = 500;

  @override
  void initState() {
    super.initState();
    final produk = widget.produk;
    if (produk != null) {
      _nameController.text = produk.namaProduk;
      _descController.text = produk.deskripsi;
      _priceController.text = produk.harga.toString();
      _stockController.text = produk.stok.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minPurchaseController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showImagePicker() async {
    if (_selectedImages.length >= 3) {
      _showSnack('Maximum 3 photos allowed.');
      return;
    }

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pick from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    final remaining = 3 - _selectedImages.length;
    if (remaining <= 0) return;

    final files = await _picker.pickMultiImage();
    if (files == null || files.isEmpty) return;

    final selected = files.take(remaining).map((x) => x.path).toList();
    if (selected.isEmpty) return;

    setState(() {
      _selectedImages.addAll(selected);
    });

    if (files.length > remaining) {
      _showSnack('Added $remaining photos. Max 3 allowed.');
    }
  }

  Future<void> _pickFromCamera() async {
    if (_selectedImages.length >= 3) {
      _showSnack('Maximum 3 photos allowed.');
      return;
    }

    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return;

    setState(() {
      _selectedImages.add(file.path);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (widget.produk == null && _selectedImages.isEmpty) {
      _showSnack('Please add at least 1 photo.');
      return;
    }

    final mainImagePath = _selectedImages.isNotEmpty
        ? _selectedImages.first
        : null;

    setState(() => _isSubmitting = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: primaryGreen)),
    );

    try {
      final provider = context.read<MarketplaceProvider>();
      bool success;

      final nama = _nameController.text.trim();
      final deskripsi = _descController.text.trim();
      final harga = int.parse(
        _priceController.text.replaceAll(RegExp('[^0-9]'), ''),
      );
      final stok = int.parse(
        _stockController.text.replaceAll(RegExp('[^0-9]'), ''),
      );
      final kategori = widget.produk?.kategori ?? '';

      if (widget.produk == null) {
        success = await provider.addProduct(
          nama: nama,
          deskripsi: deskripsi,
          harga: harga,
          stok: stok,
          kategori: kategori,
          imagePath: mainImagePath!,
        );
      } else {
        success = await provider.updateProduct(
          id: widget.produk!.id,
          nama: nama,
          deskripsi: deskripsi,
          harga: harga,
          stok: stok,
          kategori: kategori,
          imagePath: mainImagePath,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // close loading

      if (success) {
        Navigator.of(context).pop(true);
        _showSnack('Product saved successfully.');
      } else {
        _showSnack('Failed to save product.');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showSnack('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.produk != null ? 'Edit Product' : 'Add Product',
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
              // 1. Product photo box (up to 3 photos)
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
                        Text('Product Photos (max 3)', style: labelStyle),
                        Text(
                          '${_selectedImages.length}/3',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: secondaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ...List.generate(_selectedImages.length, (index) {
                          final path = _selectedImages[index];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        if (_selectedImages.length < 3)
                          GestureDetector(
                            onTap: _showImagePicker,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryGreen,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryGreen.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    color: primaryGreen,
                                    size: 28,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Add\nPhoto',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: primaryGreen,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_selectedImages.isEmpty && widget.produk != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.produk!.imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'No new photos selected. Current product photo will be kept.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Product name
              _buildInputContainer(
                label: 'Product Name',
                counter: '${_nameController.text.length}/$_nameMax',
                child: TextFormField(
                  controller: _nameController,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Enter Product Name',
                    hintStyle: hintStyle,
                    contentPadding: const EdgeInsets.only(bottom: 8),
                  ),
                  maxLength: _nameMax,
                  buildCounter:
                      (
                        _, {
                        required int currentLength,
                        required bool isFocused,
                        required int? maxLength,
                      }) => const SizedBox.shrink(),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),

              // 3. Description
              _buildInputContainer(
                label: 'Product Description',
                counter: '${_descController.text.length}/$_descMax',
                child: TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Describe your product details here...',
                    hintStyle: hintStyle,
                    contentPadding: const EdgeInsets.only(bottom: 8),
                  ),
                  maxLength: _descMax,
                  buildCounter:
                      (
                        _, {
                        required int currentLength,
                        required bool isFocused,
                        required int? maxLength,
                      }) => const SizedBox.shrink(),
                  onChanged: (_) => setState(() {}),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Description is required' : null,
                ),
              ),
              const SizedBox(height: 16),

              // 4. Detail group (price & stock)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderInput, width: 1),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Product Price',
                      _priceController,
                      'Set',
                      isCurrency: true,
                    ),
                    const Divider(color: Color(0xFFE2E2E2), thickness: 1),
                    _buildDetailRow(
                      'Product Stock',
                      _stockController,
                      'pcs/kg',
                      isNumber: true,
                    ),
                    const Divider(color: Color(0xFFE2E2E2), thickness: 1),
                    _buildDetailRow(
                      'Min. Purchase',
                      _minPurchaseController,
                      'pcs',
                      isReadOnly: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 5. Save button (full width)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 3,
                    shadowColor: primaryGreen.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Product',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 0.5,
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

  // Input container widget (name, description)
  Widget _buildInputContainer({
    required String label,
    required String counter,
    required Widget child,
  }) {
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
              if (counter.isNotEmpty)
                Text(
                  counter,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: secondaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // Detail row widget (price, stock)
  Widget _buildDetailRow(
    String label,
    TextEditingController ctrl,
    String placeholder, {
    bool isNumber = false,
    bool isReadOnly = false,
    bool isCurrency = false,
  }) {
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
                  const Text(
                    'Rp ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                Expanded(
                  child: TextFormField(
                    controller: ctrl,
                    readOnly: isReadOnly,
                    textAlign: TextAlign.end,
                    keyboardType: isNumber || isCurrency
                        ? TextInputType.number
                        : TextInputType.text,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: placeholder,
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (value) {
                      if (isReadOnly) return null;
                      if (value == null || value.isEmpty) return 'Required';
                      if ((isNumber || isCurrency) &&
                          int.tryParse(
                                value.replaceAll(RegExp(r'[^0-9]'), ''),
                              ) ==
                              null) {
                        return 'Numbers only';
                      }
                      return null;
                    },
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
