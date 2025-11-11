// lib/models/user_model.dart
class UserModel {
  final String name;
  final String nik;
  final String mobileNumber;
  final String email;
  final String address;
  final String gender;
  final String dob; // Date of Birth

  UserModel({
    required this.name,
    required this.nik,
    required this.mobileNumber,
    required this.email,
    required this.address,
    required this.gender,
    required this.dob,
  });
}