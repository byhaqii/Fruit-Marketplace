// lib/modules/profile/pages/account_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

/// ==============================
/// 1) SETTING PAGE (Sub-Screen)
/// ==============================
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF2D7F6A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              context,
              title: 'Change Password',
              icon: Icons.lock_outline,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur ganti password belum tersedia')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF2D7F6A).withOpacity(0.1), // Background hijau transparan
        borderRadius: BorderRadius.circular(25),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}

/// ==============================
/// 2) PROFILE PAGE (Edit Profile)
/// ==============================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _nikController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  late String _selectedGender;
  late String _selectedDateOfBirth;
  bool _isInitialized = false;

  static const Color primaryColor = Color(0xFF2D7F6A);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final authProvider = Provider.of<AuthProvider>(context);
      final UserModel? user = authProvider.user;

      _fullNameController = TextEditingController(text: user?.name ?? '');
      _nikController = TextEditingController(text: user?.nik ?? '');
      _mobileController = TextEditingController(text: user?.mobileNumber ?? '');
      _emailController = TextEditingController(text: user?.email ?? '');
      _addressController = TextEditingController(text: user?.address ?? '');

      _selectedGender = user?.gender ?? 'Laki-laki';
      final dob = user?.dob ?? '';

      try {
        final dateTime = DateTime.parse(dob);
        _selectedDateOfBirth = DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
      } catch (_) {
        _selectedDateOfBirth = dob.isNotEmpty ? dob : 'Pilih Tanggal';
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nikController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      final currentDobString = DateFormat('d MMMM yyyy', 'id_ID').parse(_selectedDateOfBirth);
      initialDate = currentDobString;
    } catch (_) {
      initialDate = DateTime(2000);
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar Edit
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildInputField(controller: _fullNameController, label: 'Full Name'),
            const SizedBox(height: 15),
            _buildInputField(controller: _nikController, label: 'NIK', keyboardType: TextInputType.number),
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 6), child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true, fillColor: const Color(0xFFF5F6FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(left: 4, bottom: 6), child: Text('Date of birth', style: TextStyle(color: Colors.grey, fontSize: 12))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedDateOfBirth, style: const TextStyle(color: Colors.black87, fontSize: 16)),
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 4, bottom: 6), child: Text('Gender', style: TextStyle(color: Colors.grey, fontSize: 12))),
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
            if (isSelected) const Icon(Icons.check, size: 16, color: primaryColor),
            if (isSelected) const SizedBox(width: 8),
            Text(gender, style: TextStyle(color: isSelected ? primaryColor : Colors.black87, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}


/// ==============================
/// 3) ACCOUNT PAGE (Main Screen)
/// ==============================
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  // Sesuai desain CSS
  static const Color gradientStart = Color(0xFF2D7F6A);
  static const Color gradientEnd = Color(0xFF51E5BF);
  static const Color primaryText = Color(0xFF2D7F6A);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Tinggi total layar untuk kalkulasi posisi
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // Rectangle 52 base
      body: Stack(
        children: [
          // 1. HEADER GRADIENT (Background)
          // Tinggi sekitar 35% atau fix 280px sesuai proporsi desain
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280, 
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [gradientStart, gradientEnd], // 2D7F6A -> 51E5BF
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4)),
                ],
              ),
            ),
          ),

          // 2. WHITE BODY CONTAINER (Rectangle 52)
          // Mulai dari top 190px (sesuai CSS)
          Positioned.fill(
            top: 190,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 90), // Beri ruang untuk Avatar
                child: Column(
                  children: [
                    // MENU BUTTONS (Rectangle 56, 57, dll)
                    _buildMenuButton(
                      context,
                      title: "My Profile",
                      icon: Icons.person_outline,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                    ),
                    _buildMenuButton(
                      context,
                      title: "Change Password", // Menggantikan "Setting" agar sesuai icon password
                      icon: Icons.lock_outline,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingPage())),
                    ),
                    _buildMenuButton(
                      context,
                      title: "About Us",
                      icon: Icons.info_outline,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aplikasi Fruit Marketplace v1.0')));
                      },
                    ),
                    
                    // Jarak besar sebelum Logout (sesuai desain 430px -> 641px)
                    const SizedBox(height: 50),
                    
                    _buildMenuButton(
                      context,
                      title: "Logout",
                      icon: Icons.logout,
                      isLogout: true,
                      onTap: () => _handleLogout(context, authProvider),
                    ),
                    
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),

          // 3. PROFILE INFO (Floating)
          // Posisi Top 130px (sesuai CSS)
          Positioned(
            top: 130,
            left: 30,
            right: 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end, // Agar teks sejajar bawah avatar
              children: [
                // AVATAR (Ellipse 13)
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.grey[300],
                    image: const DecorationImage(
                      // Ganti dengan foto asli jika ada
                      image: AssetImage('assets/profile_placeholder.png'), 
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  // Fallback icon jika image error
                  child: const Icon(Icons.person, size: 60, color: Colors.white),
                ),
                
                const SizedBox(width: 20),
                
                // NAMA & EMAIL
                // Layout agak turun (Top 200px di CSS)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 25.0), // Menyesuaikan posisi vertikal
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name, // "Rizal Baihaqi"
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryText, // #2D7F6A
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.verified, color: Colors.blue, size: 20), // Verified Icon
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: primaryText, // #2D7F6A
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

  // WIDGET TOMBOL MENU (Rectangle 56, 57 style)
  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      width: double.infinity,
      height: 55, // Sedikit lebih tinggi agar nyaman
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Jarak antar tombol
      decoration: BoxDecoration(
        color: const Color(0xFF2D7F6A).withOpacity(0.1), // rgba(45, 127, 106, 0.1)
        borderRadius: BorderRadius.circular(25), // Radius 25px
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: Colors.black87, size: 22),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500, // Medium
                    color: Colors.black87, // Opacity 0.9
                  ),
                ),
                if (!isLogout) ...[
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) async {
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}