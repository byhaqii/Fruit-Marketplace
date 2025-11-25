// lib/modules/Data/pages/user_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../providers/warga_provider.dart';

//======================================================================
// 1. HALAMAN LIST USER
//======================================================================
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  static const Color primaryGreen = Color(0xFF2D7F6A);
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Refresh data saat halaman dibuka
    Future.microtask(() =>
        Provider.of<WargaProvider>(context, listen: false).fetchWarga());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // HEADER
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'User Management',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // TOMBOL + NEW USER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: InkWell(
                onTap: () {
                  // Navigasi ke Form User (Mode Tambah)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserFormPage()),
                  );
                },
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '+ New User',
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black.withOpacity(0.5), width: 0.5),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search",
                    hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.w300, color: Colors.black.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search, color: Colors.black.withOpacity(0.5), size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // LIST USER
            Expanded(
              child: Consumer<WargaProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: primaryGreen));
                  }

                  final users = provider.wargaList.where((user) {
                    return user.name.toLowerCase().contains(_searchQuery) ||
                           user.email.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (users.isEmpty) {
                    return const Center(child: Text('Tidak ada data user.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(context, users[index], provider);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user, WargaProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // FOTO PROFIL
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
                // image: const DecorationImage(image: AssetImage('assets/image-1.png'), fit: BoxFit.cover), // Uncomment jika ada asset
              ),
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            
            // INFO
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w300)),
                ],
              ),
            ),

            // AKSI
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserFormPage(user: user))),
              child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.edit_outlined, size: 24)),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => _confirmDelete(context, provider, user.id),
              child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.delete_outline, size: 24)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WargaProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus User?'),
        content: const Text('Data tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteUser(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

//======================================================================
// 2. HALAMAN FORM USER (LOGIKA UTAMA TAMBAH DATA)
//======================================================================
class UserFormPage extends StatefulWidget {
  final UserModel? user;

  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _passwordController;
  String _selectedRole = 'pembeli';

  bool _isLoading = false;
  static const Color primaryGreen = Color(0xFF2D7F6A);

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.mobileNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _passwordController = TextEditingController(); 
    
    if (user != null) {
      // Pastikan role valid, kalau kosong default ke pembeli
      _selectedRole = (user.role.isNotEmpty) ? user.role : 'pembeli';
    }
  }

  // --- FUNGSI SIMPAN DATA ---
  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<WargaProvider>(context, listen: false);
    final isEdit = widget.user != null;

    // Siapkan data
    final data = {
      'name': _nameController.text,
      'email': _emailController.text,
      'role': _selectedRole,
      'mobile_number': _phoneController.text,
      'alamat': _addressController.text,
    };

    // Logika Password
    if (isEdit) {
      // Kalau edit, kirim password hanya jika diisi
      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }
    } else {
      // Kalau tambah baru, password WAJIB
      if (_passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password wajib diisi untuk user baru')));
        setState(() => _isLoading = false);
        return;
      }
      data['password'] = _passwordController.text;
    }

    bool success;
    if (isEdit) {
      success = await provider.updateUser(widget.user!.id, data);
    } else {
      success = await provider.addUser(data);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context); // Kembali ke list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'User diperbarui' : 'User ditambahkan'),
          backgroundColor: primaryGreen,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan data user'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(isEdit ? 'Edit User' : 'Tambah User', style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.person, size: 50, color: primaryGreen),
              ),
              const SizedBox(height: 30),

              _buildTextField("Nama Lengkap", _nameController),
              const SizedBox(height: 15),
              _buildTextField("Email", _emailController, inputType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              
              // DROPDOWN ROLE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role', border: InputBorder.none),
                  items: ['admin', 'penjual', 'pembeli'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role.toUpperCase()));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
              ),
              const SizedBox(height: 15),

              _buildTextField("Password", _passwordController, isObscure: true, hint: isEdit ? "(Kosongkan jika tidak ubah)" : ""),
              const SizedBox(height: 15),
              _buildTextField("No. HP", _phoneController, inputType: TextInputType.phone),
              const SizedBox(height: 15),
              _buildTextField("Alamat", _addressController, maxLines: 2),
              
              const SizedBox(height: 40),
              
              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : _saveUser,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEdit ? 'Simpan Perubahan' : 'Buat User',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isObscure = false, TextInputType inputType = TextInputType.text, int maxLines = 1, String? hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: inputType,
        maxLines: maxLines,
        validator: (v) {
          if (!isObscure && (v == null || v.isEmpty)) return "Wajib diisi";
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