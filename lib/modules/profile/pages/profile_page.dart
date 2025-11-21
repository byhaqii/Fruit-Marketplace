// lib/modules/profile/pages/profile_page.dart

import 'dart:io'; // Import untuk File
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Pastikan package ini ada
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controller Text
  late final TextEditingController _fullNameController;
  // NIK Controller dihapus sesuai permintaan
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  // State Data
  late String _selectedGender;
  late String _selectedDateOfBirth;
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
      // _nikController init dihapus
      _mobileController = TextEditingController(text: user?.mobileNumber ?? '');
      _emailController = TextEditingController(text: user?.email ?? '');
      _addressController = TextEditingController(text: user?.address ?? '');

      _selectedGender = (user?.gender != null && user!.gender.isNotEmpty) 
          ? user.gender 
          : 'Laki-laki';
      
      final dob = user?.dob ?? '';
      try {
        if (dob.isNotEmpty) {
           final dateTime = DateTime.parse(dob);
           _selectedDateOfBirth = DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
        } else {
           _selectedDateOfBirth = 'Pilih Tanggal';
        }
      } catch (_) {
        _selectedDateOfBirth = dob.isNotEmpty ? dob : 'Pilih Tanggal';
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    // _nikController dispose dihapus
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- LOGIC AMBIL GAMBAR ---
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
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
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengambil gambar"))
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      initialDate = DateFormat('d MMMM yyyy', 'id_ID').parse(_selectedDateOfBirth);
    } catch (_) {
      initialDate = DateTime(2000);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = DateFormat('d MMMM yyyy', 'id_ID').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- 1. AVATAR EDITABLE ---
            Center(
              child: GestureDetector(
                onTap: _pickImage, // Klik untuk ganti foto
                child: Stack(
                  children: [
                    Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE0E0E0),
                        border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                        image: _imageFile != null 
                            ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                            : null, // TODO: Bisa tambah NetworkImage user.imageUrl jika ada
                      ),
                      child: _imageFile == null 
                          ? const Icon(Icons.person, size: 65, color: Colors.white)
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
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // --- 2. FORM FIELDS (NIK DIHAPUS) ---
            _buildInputField(controller: _fullNameController, label: 'Full Name'),
            
            // Input NIK dihapus di sini
            
            const SizedBox(height: 15),
            _buildDatePickerField(context),
            
            const SizedBox(height: 15),
            _buildGenderSelection(),
            
            const SizedBox(height: 15),
            _buildInputField(controller: _mobileController, label: 'Mobile number', keyboardType: TextInputType.phone),
            
            const SizedBox(height: 15),
            _buildInputField(controller: _emailController, label: 'Email', readOnly: true),
            
            const SizedBox(height: 15),
            _buildInputField(controller: _addressController, label: 'Address', maxLines: 2),
            
            const SizedBox(height: 40),
            
            // --- 3. SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Kirim data (_fullNameController.text, _imageFile, dll) ke Provider/API
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perubahan disimpan (Simulasi)!'))
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 3,
                  shadowColor: primaryColor.withOpacity(0.4),
                ),
                child: const Text(
                  'Save Changes', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Input Field
  Widget _buildInputField({
    required TextEditingController controller, 
    required String label, 
    TextInputType keyboardType = TextInputType.text, 
    int maxLines = 1, 
    bool readOnly = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6), 
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Poppins'))
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  // Widget Helper untuk Date Picker
  Widget _buildDatePickerField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 6), 
            child: Text('Date of birth', style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Poppins'))
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDateOfBirth, 
                  style: const TextStyle(color: Colors.black87, fontSize: 16, fontFamily: 'Poppins')
                ),
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Gender
  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6), 
          child: Text('Gender', style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Poppins'))
        ),
        Row(
          children: [
            Expanded(child: _buildGenderOption('Laki-laki')),
            const SizedBox(width: 15),
            Expanded(child: _buildGenderOption('Perempuan')),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender) {
    final bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: primaryColor) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 16, color: primaryColor),
              const SizedBox(width: 8),
            ],
            Text(
              gender, 
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.black87, 
                fontWeight: FontWeight.w600, 
                fontFamily: 'Poppins'
              )
            ),
          ],
        ),
      ),
    );
  }
}