// lib/modules/profile/pages/account_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// Pastikan import ini sesuai dengan struktur project Anda
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';

// ==========================================
// CONSTANTS & THEME
// ==========================================
const Color kPrimaryColor = Color(0xFF2D7F6A);
const Color kSecondaryColor = Color(0xFF51E5BF);
const Color kBackgroundColor = Color(0xFFF5F6FA);
const Color kInputFillColor = Color(0xFFF0F3F6);

// ==========================================
// 1. CHANGE PASSWORD PAGE
// ==========================================
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          // HEADER
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
                    "Back",
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
          // BODY
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.black87),
                      SizedBox(width: 10),
                      Text(
                        "Change Password",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(),
                  ),
                  const Text(
                    "Your password must be at least 6 characters and should include a combination of numbers, letters and special characters (!\$@%)",
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 25),
                  _buildPasswordField("Current password"),
                  const SizedBox(height: 15),
                  _buildPasswordField("New password"),
                  const SizedBox(height: 15),
                  _buildPasswordField("Re-type new password"),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password changed successfully!')),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String hint) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: kPrimaryColor),
        ),
      ),
    );
  }
}

// ==========================================
// 2. ABOUT US PAGE
// ==========================================
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
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
                    "Back",
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
          Container(
            margin: const EdgeInsets.only(top: 140),
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "About Us",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 120,
                    width: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.local_grocery_store, size: 60, color: Colors.orange),
                  ),
                  const Text(
                    "FRUITIFY",
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.w900, 
                      color: kPrimaryColor,
                      letterSpacing: 2
                    ),
                  ),
                  const Text("F R U I T  S T O R E", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 30),
                  const Text(
                    "Fruitify is a local fruit marketplace designed to connect people within the same village or neighborhood with the freshest fruits around them. Our mission is to make fruit shopping easier, faster, and more enjoyable for everyone.\n\n"
                    "With Fruitify, users can discover various fruits sold by local farmers and sellers simply by scanning the fruit using our smart recognition feature. No more guessing, searching manually, or wasting time—just scan, find, and buy instantly.\n\n"
                    "We aim to support local communities by helping small fruit sellers reach more customers, while also giving users a convenient way to access fresh, high-quality produce close to home.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.6, fontSize: 13),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Fresh fruits. Local sellers. Smart shopping.\nThat's Fruitify.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. EDIT PROFILE PAGE
// ==========================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = Provider.of<AuthProvider>(context).user;
      _nameController = TextEditingController(text: user?.name ?? 'Muhammad Rizal Al Baihaqi');
      _mobileController = TextEditingController(text: user?.mobileNumber ?? '0822-2847-2871');
      _emailController = TextEditingController(text: user?.email ?? 'mrizalalbaihaqi@gmail.com');
      _addressController = TextEditingController(text: user?.address ?? 'Jl. Bareng Raya 2N 550c');
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
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
                    "Profile",
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
          Container(
            margin: const EdgeInsets.only(top: 140),
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 70, 25, 20),
              child: Column(
                children: [
                  _buildInput("Full Name", _nameController),
                  const SizedBox(height: 15),
                  _buildInput("Mobile number", _mobileController, isNumber: true),
                  const SizedBox(height: 15),
                  _buildInput("Email", _emailController, isReadOnly: true),
                  const SizedBox(height: 15),
                  _buildInput("Address", _addressController, maxLines: 2),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated!')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // FLOATING AVATAR
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      // PERBAIKAN: Saya comment bagian image agar tidak error
                      // image: const DecorationImage(
                      //   image: AssetImage('assets/profile_placeholder.png'),
                      //   fit: BoxFit.cover,
                      // ),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.person, color: Colors.grey, size: 50),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, size: 16, color: kPrimaryColor),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isNumber = false, bool isReadOnly = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kPrimaryColor, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: kInputFillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 4. MAIN ACCOUNT PAGE
// ==========================================
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kPrimaryColor, kSecondaryColor],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 200),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: ListView(
              padding: const EdgeInsets.only(top: 90, bottom: 30),
              children: [
                _buildMenuButton(
                  context, 
                  "My Profile", 
                  Icons.person_outline, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()))
                ),
                _buildMenuButton(
                  context, 
                  "Change Password", 
                  Icons.vpn_key_outlined, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()))
                ),
                _buildMenuButton(
                  context, 
                  "About Us", 
                  Icons.info_outline, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage()))
                ),
                const SizedBox(height: 50),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: kInputFillColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ListTile(
                    onTap: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    },
                    leading: const Icon(Icons.logout, color: Colors.black87),
                    title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          // FLOATING PROFILE INFO
          Positioned(
            top: 140,
            left: 25,
            right: 25,
            child: Row(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                    // PERBAIKAN: Saya comment bagian image agar tidak error
                    // image: const DecorationImage(
                    //   image: AssetImage('assets/profile_placeholder.png'), 
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                  child: const Icon(Icons.person, color: Colors.grey, size: 50),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.verified, color: Colors.blue, size: 18)
                          ],
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: kInputFillColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}