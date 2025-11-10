// file profile_page.dart
import 'package:flutter/material.dart';
import '/../models/user_model.dart'; // Ganti path ini jika perlu

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Menggunakan data dummy
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
    final DateTime? picked = await showDatePicker(
      context: context,
      // Jika format user.dob tidak standar DateTime, ini akan error. 
      // Asumsikan user.dob diformat dengan baik atau berikan default.
      initialDate: DateTime.tryParse(user.dob.replaceAll(RegExp(r'[a-zA-Z]'), '')) ?? DateTime(2000), 
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
            _buildGenderSelection(),
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

  // --- PRIVATE METHODS ---
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

  Widget _buildGenderSelection() {
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
              child: _buildGenderOption('Male'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderOption('Female'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender) {
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
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
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
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            Text(gender),
          ],
        ),
      ),
    );
  }
}
