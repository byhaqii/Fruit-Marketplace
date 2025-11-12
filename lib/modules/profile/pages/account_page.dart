// folder profile/pages file account_page.dart (Unified File)

import 'package:flutter/material.dart';
import '../../../models/user_model.dart'; 

// --- 1. SETTING PAGE (Sub-Screen) ---

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Text(
              'Customize Your Privacy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            _buildSettingTile(
              context,
              title: 'Biometric Login',
              isSwitch: true,
            ),
            const SizedBox(height: 16),

            _buildSettingTile(
              context,
              title: 'Change Password',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigasi ke halaman Ganti Password')),
                );
              },
            ),
            const SizedBox(height: 16),

            _buildSettingTile(
              context,
              title: 'Logout Semua Perangkat',
              trailing: const Icon(Icons.logout, color: Colors.black54),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout Semua Perangkat...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
      BuildContext context, {
        required String title,
        Widget? trailing,
        bool isSwitch = false,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: isSwitch ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (isSwitch)
              Switch(
                value: true, // Nilai dummy
                onChanged: (bool value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Biometric Login: ${value ? 'On' : 'Off'}')),
                  );
                },
                activeThumbColor: Theme.of(context).colorScheme.primary,
              )
            else
              trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

// --- 2. PROFILE PAGE (Sub-Screen) ---

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserModel user = UserModel.dummyUser;
  
  late TextEditingController _fullNameController;
  late TextEditingController _nikController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  late String _selectedGender;
  late String _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: user.name);
    _nikController = TextEditingController(text: user.nik);
    _mobileController = TextEditingController(text: user.mobileNumber);
    _emailController = TextEditingController(text: user.email);
    _addressController = TextEditingController(text: user.address);
    _selectedGender = user.gender;
    _selectedDateOfBirth = user.dob; // Menggunakan format string dari dummy user
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
      // Mencoba parse tanggal dari user.dob (jika formatnya string yang dipahami)
      initialDate = DateTime.parse(user.dob.replaceAll(RegExp(r'[a-zA-Z]'), '').trim()); 
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
        // Format tanggal sederhana: "12 June 2004"
        _selectedDateOfBirth = "${picked.day} ${[
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ][picked.month - 1]} ${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar Profil
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  backgroundImage: const NetworkImage(
                      'https://picsum.photos/200/200'), 
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildInputField(controller: _fullNameController, label: 'Full Name'),
            const SizedBox(height: 16),
            _buildInputField(controller: _nikController, label: 'NIK', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildDatePickerField(context),
            const SizedBox(height: 16),
            _buildGenderSelection(primaryColor),
            const SizedBox(height: 16),
            _buildInputField(controller: _mobileController, label: 'Mobile number', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildInputField(controller: _emailController, label: 'Email', keyboardType: TextInputType.emailAddress, readOnly: true),
            const SizedBox(height: 16),
            _buildInputField(controller: _addressController, label: 'Address', maxLines: 1),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, MediaQuery.of(context).padding.bottom + 8.0),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil berhasil disimpan!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }

  // --- PRIVATE METHODS FOR PROFILE PAGE ---
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
          padding: const EdgeInsets.only(left: 12.0, bottom: 4),
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          const Padding(
            padding: EdgeInsets.only(left: 12.0, bottom: 4),
            child: Text('Date of birth', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDateOfBirth,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12.0, bottom: 4),
          child: Text('Gender', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption('Male', primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderOption('Female', primaryColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, Color primaryColor) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: primaryColor, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: gender,
              groupValue: _selectedGender,
              onChanged: (String? value) {
                setState(() {
                  _selectedGender = value!; 
                });
              },
              activeColor: primaryColor,
            ),
            Text(gender),
          ],
        ),
      ),
    );
  }
}

// --- 3. ACCOUNT PAGE (Main Screen/Dashboard Target) ---

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  // Warna utama
  static const Color primaryGreen = Color.fromARGB(255, 56, 142, 60);

  // Konstanta ukuran layout
  static const double _headerHeight = 150;
  static const double _avatarRadius = 46;
  static const double _avatarTopOverlap = 20;
  static const double _textStartPadding = 16.0;
  static const double _avatarLeftPadding = 20;

  @override
  Widget build(BuildContext context) {
    final UserModel user = UserModel.dummyUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderWithCombinedInfo(user),

            // Menu utama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // My Profile
                  _buildMenuTile(
                    context,
                    title: 'My Profile',
                    icon: Icons.person_outline,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()), 
                    ),
                  ),
                  // Setting
                  _buildMenuTile(
                    context,
                    title: 'Setting',
                    icon: Icons.settings_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingPage()), 
                    ),
                  ),
                  // About App
                  _buildMenuTile(
                    context,
                    title: 'About App',
                    icon: Icons.info_outline,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Aplikasi E-Commerce v1.0'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLogoutTile(context),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header berisi background hijau, avatar, dan teks user info
  Widget _buildHeaderWithCombinedInfo(UserModel user) {
    const double greenHeight = _headerHeight - _avatarTopOverlap;
    const double stackHeight = _headerHeight + _avatarRadius;

    final double avatarAreaWidth = (_avatarRadius * 2) + _avatarLeftPadding;
    const double textHorizontalOffset = 16;

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background hijau
          Container(
            height: greenHeight,
            width: double.infinity,
            color: primaryGreen,
          ),

          // Avatar
          Positioned(
            left: _avatarLeftPadding,
            top: greenHeight - _avatarRadius,
            child: const CircleAvatar(
              radius: _avatarRadius,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage('https://picsum.photos/200/200'),
            ),
          ),

          // Nama & Email
          Positioned(
            top: greenHeight + 10,
            left: avatarAreaWidth + textHorizontalOffset,
            right: _textStartPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk setiap item menu
  Widget _buildMenuTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.black54),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget untuk tombol logout
  Widget _buildLogoutTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logging out...')),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.black54),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}