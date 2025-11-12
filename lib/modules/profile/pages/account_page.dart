// lib/profile/pages/account_page.dart (Unified File - rewritten)
// Pastikan path UserModel sesuai proyekmu.
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

/// ==============================
/// 1) SETTING PAGE (Sub-Screen)
/// ==============================
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

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
                color: primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Customize Your Privacy',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
              trailing:
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
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
    final primary = Theme.of(context).colorScheme.primary;

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
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            if (isSwitch)
              Switch(
                value: true,
                onChanged: (bool value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Biometric Login: ${value ? 'On' : 'Off'}')),
                  );
                },
                activeThumbColor: primary,
              )
            else
              trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

/// ==============================
/// 2) PROFILE PAGE (Sub-Screen)
/// ==============================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dummy user - pastikan UserModel.dummyUser tersedia
  final UserModel user = UserModel.dummyUser;

  late final TextEditingController _fullNameController;
  late final TextEditingController _nikController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  late String _selectedGender;
  late String _selectedDateOfBirth;

  // Constants (sinkron dengan AccountPage)
  static const Color primaryGreen = Color.fromARGB(255, 56, 142, 60);
  static const double _headerHeight = 150;
  static const double _avatarRadius = 46;
  static const double _avatarTopOverlap = 20;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: user.name);
    _nikController = TextEditingController(text: user.nik);
    _mobileController = TextEditingController(text: user.mobileNumber);
    _emailController = TextEditingController(text: user.email);
    _addressController = TextEditingController(text: user.address);

    _selectedGender = user.gender;
    _selectedDateOfBirth = user.dob;
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
      // Coba parse tanggal dari user.dob (basic)
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
        _selectedDateOfBirth =
            "${picked.day} ${_monthName(picked.month)} ${picked.year}";
      });
    }
  }

  String _monthName(int m) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[m - 1];
  }

  Widget _buildProfileHeader() {
    const double greenHeight = _headerHeight - _avatarTopOverlap;
    const double stackHeight = _headerHeight + _avatarRadius;

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(height: greenHeight, width: double.infinity, color: primaryGreen),
          Positioned(
            top: greenHeight - _avatarRadius,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: _avatarRadius,
                  backgroundColor: Colors.white,
                  backgroundImage: const NetworkImage('https://picsum.photos/200/200'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildInputField(controller: _fullNameController, label: 'Full Name'),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _nikController,
                    label: 'NIK',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildDatePickerField(context),
                  const SizedBox(height: 16),
                  _buildGenderSelection(primaryColor),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _mobileController,
                    label: 'Mobile number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(controller: _addressController, label: 'Address', maxLines: 1),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.fromLTRB(16.0, 8.0, 16.0, MediaQuery.of(context).padding.bottom + 8.0),
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

  // PRIVATE HELPERS
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
            decoration:
                BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedDateOfBirth, style: const TextStyle(color: Colors.black, fontSize: 16)),
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
            Expanded(child: _buildGenderOption('Male', primaryColor)),
            const SizedBox(width: 16),
            Expanded(child: _buildGenderOption('Female', primaryColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, Color primaryColor) {
    final bool isSelected = _selectedGender == gender;

    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: primaryColor, width: 2) : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: gender,
              groupValue: _selectedGender,
              onChanged: (String? value) => setState(() => _selectedGender = value!),
              activeColor: primaryColor,
            ),
            Text(gender),
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

  // Warna utama dan layout constants
  static const Color primaryGreen = Color.fromARGB(255, 56, 142, 60);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildMenuTile(
                    context,
                    title: 'My Profile',
                    icon: Icons.person_outline,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ),
                  ),
                  _buildMenuTile(
                    context,
                    title: 'Setting',
                    icon: Icons.settings_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingPage()),
                    ),
                  ),
                  _buildMenuTile(
                    context,
                    title: 'About App',
                    icon: Icons.info_outline,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Aplikasi E-Commerce v1.0')),
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
          Container(height: greenHeight, width: double.infinity, color: primaryGreen),
          Positioned(
            left: _avatarLeftPadding,
            top: greenHeight - _avatarRadius,
            child: const CircleAvatar(
              radius: _avatarRadius,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage('https://picsum.photos/200/200'),
            ),
          ),
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
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
