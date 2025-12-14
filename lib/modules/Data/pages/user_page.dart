import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../providers/warga_provider.dart';

// Color Constants
const Color primaryGreen = Color(0xFF2D7F6A);
const Color accentPurple = Color(0xFF8979FF);
const Color accentOrange = Color(0xFFFF9800);

//======================================================================
// 1. HALAMAN LIST USER (TAMPILAN SESUAI DESAIN CSS)
//======================================================================
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Ambil data user saat halaman dibuka
    Future.microtask(
      () => Provider.of<WargaProvider>(context, listen: false).fetchWarga(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GRADIENT HEADER ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryGreen, primaryGreen.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(30, 22, 30, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.people_alt_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Management',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Manage all users',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- TOMBOL + NEW USER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserFormPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryGreen, primaryGreen.withOpacity(0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 19),
                      SizedBox(width: 8),
                      Text(
                        'New User',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.toLowerCase()),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search by name or email",
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.black.withOpacity(0.4),
                      size: 18,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                            child: Icon(
                              Icons.clear_rounded,
                              color: Colors.black.withOpacity(0.4),
                              size: 16,
                            ),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- LIST USER ---
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Provider.of<WargaProvider>(
                    context,
                    listen: false,
                  ).fetchWarga();
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                color: primaryGreen,
                backgroundColor: Colors.white,
                child: Consumer<WargaProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryGreen),
                      );
                    }

                    // Filter pencarian
                    final users = provider.wargaList.where((user) {
                      return user.name.toLowerCase().contains(_searchQuery) ||
                          user.email.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (users.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.person_off_rounded,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No users found',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return _buildUserCard(context, users[index], provider);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Kartu User (Rectangle 109 style)
  Widget _buildUserCard(
    BuildContext context,
    UserModel user,
    WargaProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Foto Profil dengan Gradient Background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentPurple, accentOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/image-1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const SizedBox(width: 16),
            const SizedBox(width: 10),

            // Nama & Email
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 5),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Tombol Edit
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserFormPage(user: user)),
                );
              },
              borderRadius: BorderRadius.circular(7),
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: primaryGreen,
                    size: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 4),
            const SizedBox(width: 6),
            const SizedBox(width: 4),

            // Tombol Delete
            InkWell(
              onTap: () => _confirmDelete(context, provider, user.id),
              borderRadius: BorderRadius.circular(7),
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
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
        title: const Text("Hapus User?"),
        content: const Text("Data yang dihapus tidak dapat dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteUser(id);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

//======================================================================
// 2. HALAMAN FORM USER (LOGIKA SUDAH FIX UNTUK BACKEND BARU)
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
    _phoneController = TextEditingController(
      text: user?.mobileNumber ?? '',
    ); // Pakai mobileNumber
    _addressController = TextEditingController(text: user?.address ?? '');
    _passwordController = TextEditingController();

    if (user != null && user.role.isNotEmpty) {
      _selectedRole = user.role;
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<WargaProvider>(context, listen: false);
    final isEdit = widget.user != null;

    // DATA YANG DIKIRIM KE BACKEND (Sesuai Tabel Baru)
    final data = {
      'name': _nameController.text,
      'email': _emailController.text,
      'role': _selectedRole,
      'mobile_number': _phoneController.text, // PENTING: Sesuai migrasi
      'alamat': _addressController.text, // PENTING: Sesuai migrasi
    };

    if (isEdit) {
      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }
    } else {
      if (_passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password wajib diisi untuk user baru')),
        );
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Data berhasil diperbarui' : 'User baru ditambahkan',
          ),
          backgroundColor: primaryGreen,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan data. Cek koneksi/input.'),
          backgroundColor: Colors.red,
        ),
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
        title: Text(
          isEdit ? 'Edit User' : 'New User',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Ilustrasi Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryGreen, width: 2),
                ),
                child: const Icon(Icons.person, size: 50, color: primaryGreen),
              ),
              const SizedBox(height: 30),

              _buildTextField("Full Name", _nameController),
              const SizedBox(height: 15),
              _buildTextField(
                "Email Address",
                _emailController,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // Dropdown Role
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: InputBorder.none,
                  ),
                  items: ['admin', 'penjual', 'pembeli'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
              ),
              const SizedBox(height: 15),

              _buildTextField(
                "Password",
                _passwordController,
                isObscure: true,
                hint: isEdit ? "(Isi jika ingin mengubah)" : "Min. 6 karakter",
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "Phone Number",
                _phoneController,
                inputType: TextInputType.phone,
              ), // Masuk ke mobile_number
              const SizedBox(height: 15),
              _buildTextField("Address", _addressController, maxLines: 2),

              const SizedBox(height: 40),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveUser,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? 'Save Changes' : 'Create User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isObscure = false,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: inputType,
        maxLines: maxLines,
        validator: (v) {
          if (!isObscure && (v == null || v.isEmpty)) return "Required";
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
