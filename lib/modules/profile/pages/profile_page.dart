// lib/modules/profile/pages/profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../config/env.dart'; // <<< FIX 1: Import Env

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controller Text
  late final TextEditingController _fullNameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  // State Data
  bool _isInitialized = false;

  // State Image Picker
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  static const Color primaryColor = Color(0xFF2D7F6A);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final authProvider = Provider.of<AuthProvider>(context);
      final UserModel? user = authProvider.user;

      _fullNameController = TextEditingController(text: user?.name ?? '');
      _mobileController = TextEditingController(text: user?.mobileNumber ?? '');
      _emailController = TextEditingController(text: user?.email ?? '');
      _addressController = TextEditingController(text: user?.address ?? '');

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Helper untuk mendapatkan URL dasar storage
  String _getStorageBaseUrl() {
    // FIX 2: Gunakan Env.apiBaseUrl secara konsisten
    String baseUrl = Env.apiBaseUrl;
    // Cek dan hapus trailing '/api' jika ada, untuk mendapatkan base domain/IP
    return baseUrl.endsWith('/api')
        ? baseUrl.replaceFirst('/api', '')
        : baseUrl;
  }

  // Helper untuk membentuk URL Avatar lengkap
  String getAvatarUrl(String? filename) {
    if (filename == null || filename.isEmpty) return '';
    return '${_getStorageBaseUrl()}/storage/profiles/$filename';
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: primaryColor),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(ctx);
                _processImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: primaryColor),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _processImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengambil gambar")));
    }
  }

  // --- LOGIC UPDATE PROFILE ---
  Future<void> _updateProfile() async {
    if (_fullNameController.text.isEmpty || _mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan Nomor HP wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Tampilkan Loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            const Center(child: CircularProgressIndicator(color: primaryColor)),
      );

      await authProvider.updateProfile(
        name: _fullNameController.text,
        email: _emailController.text,
        alamat: _addressController.text,
        mobileNumber: _mobileController.text,
        avatarPath: _imageFile?.path,
      );

      if (mounted) Navigator.pop(context); // Tutup Loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: primaryColor,
          ),
        );
        // Penting: Hapus file lokal agar NetworkImage yang baru dimuat
        setState(() {
          _imageFile = null;
        });
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tutup Loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal update profil: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final user = Provider.of<AuthProvider>(context).user;

    // LOGIKA UNTUK MENENTUKAN SUMBER GAMBAR
    ImageProvider? avatarImage;
    if (_imageFile != null) {
      avatarImage = FileImage(_imageFile!);
    } else if (user?.avatar != null && user!.avatar!.isNotEmpty) {
      avatarImage = NetworkImage(getAvatarUrl(user.avatar!));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2D7F6A),
      body: Stack(
        children: [
          // Header
          SafeArea(
            child: Container(
              height: 180,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body
          Container(
            margin: const EdgeInsets.only(top: 140),
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
              child: Column(
                children: [
                  // --- 1. AVATAR EDITABLE ---
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE0E0E0),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.2),
                                width: 2,
                              ),
                              image: avatarImage != null
                                  ? DecorationImage(
                                      image: avatarImage,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: avatarImage == null
                                ? const Icon(
                                    Icons.person,
                                    size: 65,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 2. FORM FIELDS ---
                  _buildInputField(
                    controller: _fullNameController,
                    label: 'Full Name',
                  ),

                  const SizedBox(height: 15),
                  _buildInputField(
                    controller: _mobileController,
                    label: 'Mobile number',
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 15),
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email',
                    readOnly: true,
                  ),

                  const SizedBox(height: 15),
                  _buildInputField(
                    controller: _addressController,
                    label: 'Address',
                    maxLines: 2,
                  ),

                  const SizedBox(height: 40),

                  // --- 3. SAVE BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 3,
                        shadowColor: primaryColor.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Input Field (Tetap Sama)
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
