// lib/pages/user_page.dart
// Berisi UserListPage dan UserDetailPage

import 'package:flutter/material.dart';
// Sesuaikan path ini dengan lokasi file model Anda yang sudah paten
import '/../models/user_model.dart'; 

//======================================================================
// Halaman Daftar Pengguna (List Page)
//======================================================================
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  // Buat daftar dummy users untuk ditampilkan
  final List<UserModel> users = List.generate(
    8,
    (index) => UserModel.simulatedApiUser, // Menggunakan data simulasi
  );

  final Color primaryColor = const Color(0xFF3B8A7D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.person, color: primaryColor),
        title: Text(
          'User Management',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Tombol + New User
            ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New User', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Aksi untuk menambah user baru
              },
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar User
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildUserCard(context, user);
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom bar & FAB tidak ada di sini (karena sudah ada di Dashboard)
    );
  }

  // Widget untuk satu item di daftar user
  Widget _buildUserCard(BuildContext context, UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue.shade700),
              onPressed: () {
                // Navigasi ke Halaman Detail
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Langsung panggil UserDetailPage
                    builder: (context) => UserDetailPage(user: user),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade700),
              onPressed: () {
                // Aksi untuk hapus user
              },
            ),
          ],
        ),
      ),
    );
  }
}

//======================================================================
// Halaman Detail Pengguna (Detail Page)
//======================================================================
class UserDetailPage extends StatelessWidget {
  final UserModel user;
  
  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF3B8A7D);
    const Color fillColor = Color(0xFFEAF1EF); // Warna isian field

    return Scaffold(
      appBar: AppBar(
        title: const Text('Back'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 32),

              // Form Fields
              _buildTextField(label: 'Full Name', initialValue: user.name, fillColor: fillColor),
              _buildTextField(label: 'Email', initialValue: user.email, fillColor: fillColor),
              _buildTextField(label: 'Phone Number', initialValue: user.mobileNumber, fillColor: fillColor),
              _buildTextField(label: 'Alamat', initialValue: user.address, fillColor: fillColor),
            ],
          ),
        ),
      ),
      // Tombol Save di bagian bawah
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // Aksi untuk menyimpan data
            Navigator.pop(context); // Kembali ke halaman list
          },
          child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  // Helper widget untuk membuat text field
  Widget _buildTextField({required String label, required String initialValue, required Color fillColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}