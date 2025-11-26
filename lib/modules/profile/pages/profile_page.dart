// lib/modules/profile/pages/profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../providers/auth_provider.dart';
import '../../../models/user_model.dart'; // Pastikan ini diimport jika belum

class ProfilePage extends StatefulWidget {
   const ProfilePage({super.key});

   @override
   State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
 // Controllers
 late TextEditingController _nameController;
 late TextEditingController _emailController;
 late TextEditingController _phoneController;
 late TextEditingController _addressController;
 late TextEditingController _passwordController;
 
 // Image State
 File? _imageFile;
 final ImagePicker _picker = ImagePicker();
 
 static const Color primaryGreen = Color(0xFF2D7F6A);
 
 // !!! PENTING: GANTI DENGAN URL BACKEND ANDA YANG SEBENARNYA !!!
 // Contoh: 'http://192.168.1.10:8000' atau domain Anda
 static const String BASE_URL = 'http://[YOUR_BASE_URL_HERE]'; 

 @override
 void initState() {
  super.initState();
    // Menggunakan WidgetsBinding.instance.addPostFrameCallback untuk mengakses Provider di initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      
      _nameController = TextEditingController(text: user?.name ?? '');
      _emailController = TextEditingController(text: user?.email ?? '');
      _phoneController = TextEditingController(text: user?.mobileNumber ?? ''); 
      _addressController = TextEditingController(text: user?.address ?? '');
      _passwordController = TextEditingController();
      
      // Jika Anda ingin menginisialisasi controller di initState, pastikan 
      // Anda memindahkan logika inisialisasi controller ke sini (setelah fetch user),
      // atau gunakan didChangeDependencies seperti pada contoh kode asli jika itu lebih pas.
      // Namun untuk kasus ini, solusi di atas (menggunakan addPostFrameCallback) 
      // sudah cukup jika Anda hanya ingin menampilkan data awal.
    });
  
  _nameController = TextEditingController();
  _emailController = TextEditingController();
  _phoneController = TextEditingController(); 
  _addressController = TextEditingController();
  _passwordController = TextEditingController();
 }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<AuthProvider>(context).user;
    if (user != null) {
      // Pastikan data diisi/diperbarui saat didChangeDependencies dipanggil 
      // (terutama saat pertama kali widget dibangun)
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.mobileNumber ?? '';
      _addressController.text = user.address ?? '';
    }
  }
 
 @override
 void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  _addressController.dispose();
  _passwordController.dispose();
  super.dispose();
 }

 // Helper untuk membuat URL Avatar lengkap
 String getAvatarUrl(String? filename) {
  // Path penyimpanan di backend (Laravel) adalah public/storage/profiles/
  if (filename == null || filename.isEmpty) {
   return ''; 
  }
  return '$BASE_URL/storage/profiles/$filename';
 }
 
 // ---------------------- LOGIC UPLOAD IMAGE ----------------------
 Future<void> _pickImage() async {
  final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  if (picked != null) {
   setState(() {
    _imageFile = File(picked.path);
   });
  }
 }

 Future<void> _updateProfile() async {
  if (!_formKey.currentState!.validate()) return;
  
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  try {
   showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator(color: primaryGreen)),
   );

   await authProvider.updateProfile(
    name: _nameController.text,
    email: _emailController.text,
    alamat: _addressController.text,
    mobileNumber: _phoneController.text,
    password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
    avatarPath: _imageFile?.path,
   );

   if (mounted) Navigator.pop(context); 
   if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: primaryGreen),
    );
        // Opsional: Hapus file lokal setelah berhasil diupload/disimpan
        setState(() {
          _imageFile = null;
        });
   }

  } catch (e) {
   if (mounted) Navigator.pop(context); 
   if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
    );
   }
  }
 }

 @override
 Widget build(BuildContext context) {
  final user = Provider.of<AuthProvider>(context).user; 

  // Tentukan sumber gambar avatar
  ImageProvider? avatarImage;
  
  if (_imageFile != null) {
    // Prioritas 1: Gambar baru yang dipilih dari galeri/kamera
    avatarImage = FileImage(_imageFile!);
  } else if (user?.avatar != null && user!.avatar!.isNotEmpty) {
    // Prioritas 2: Avatar dari server (Network Image)
    avatarImage = NetworkImage(getAvatarUrl(user.avatar!)); // URL digenerate oleh helper function
  } 
    // Jika tidak ada (null), avatarImage tetap null, dan Icon placeholder akan ditampilkan.

  return Scaffold(
   appBar: AppBar(
    title: const Text('My Profile', style: TextStyle(color: Colors.white)),
    backgroundColor: primaryGreen,
    iconTheme: const IconThemeData(color: Colors.white),
   ),
   body: SingleChildScrollView(
    padding: const EdgeInsets.all(25.0),
    child: Form(
     key: _formKey,
     child: Column(
      children: [
       // 1. Avatar Area (Dapat Diklik)
       GestureDetector(
        onTap: _pickImage,
        child: Container(
         width: 100, height: 100,
         decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
          border: Border.all(color: primaryGreen, width: 2),
          // Gunakan DecorationImage hanya jika avatarImage tidak null
          image: avatarImage != null 
            ? DecorationImage(image: avatarImage, fit: BoxFit.cover) 
            : null,
         ),
         // Tampilkan Icon hanya jika avatarImage null (fallback)
         child: avatarImage == null 
           ? const Icon(Icons.person, size: 50, color: Colors.grey) 
           : null,
        ),
       ),
       TextButton(
        onPressed: _pickImage,
        child: const Text("Ganti Foto Profil", style: TextStyle(color: primaryGreen)),
       ),
       const SizedBox(height: 30),

       // 2. Form Fields
       _buildTextField("Full Name", _nameController),
       const SizedBox(height: 15),
       _buildTextField("Email Address", _emailController, inputType: TextInputType.emailAddress, isEditable: false),
       const SizedBox(height: 15),
       _buildTextField("Phone Number", _phoneController, inputType: TextInputType.phone),
       const SizedBox(height: 15),
       _buildTextField("Address", _addressController, maxLines: 2),
       const SizedBox(height: 15),
       
       // New Password Field
       _buildTextField(
        "New Password", 
        _passwordController, 
        isObscure: true, 
        hint: "Isi hanya jika ingin mengganti password",
        isPassword: true,
       ),
       
       const SizedBox(height: 40),
       
       // 3. Tombol Simpan
       SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
         style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
         ),
         onPressed: _updateProfile,
         child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
       ),
      ],
     ),
    ),
   ),
  );
 }

 Widget _buildTextField(String label, TextEditingController controller, {bool isObscure = false, TextInputType inputType = TextInputType.text, int maxLines = 1, String? hint, bool isEditable = true, bool isPassword = false}) {
  return Container(
   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
   decoration: BoxDecoration(
    color: isEditable ? const Color(0xFFF5F5F5) : const Color(0xFFE0E0E0),
    borderRadius: BorderRadius.circular(10),
   ),
   child: TextFormField(
    controller: controller,
    obscureText: isObscure,
    keyboardType: inputType,
    maxLines: maxLines,
    readOnly: !isEditable,
    validator: (v) {
     // Validasi wajib diisi untuk field non-password
     if (!isPassword && (v == null || v.isEmpty)) return "Wajib diisi";
     
     // Validasi minimum length untuk password baru (jika diisi)
     if (isPassword && v!.isNotEmpty && v.length < 6) return "Password min. 6 karakter";
     
     return null;
    },
    decoration: InputDecoration(
     labelText: label,
     hintText: hint,
     border: InputBorder.none,
     labelStyle: const TextStyle(color: Colors.grey),
    ),
   ),
  );
  }
}