// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String nik;
  final String dob; 
  final String gender;
  final String mobileNumber;
  final String address;
  final String? avatar; // <--- ADDED: Field untuk URL Avatar

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.nik = '',
    this.dob = '',
    this.gender = '',
    this.mobileNumber = '',
    this.address = '',
    this.avatar, // <--- ADDED
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['nama'] ?? json['name'] ?? 'No Name', 
      email: json['email'] ?? '',
      role: json['role']?.toString() ?? 'pembeli', 
      nik: json['nik'] ?? '',
      dob: json['tanggal_lahir'] ?? '',
      gender: json['jenis_kelamin'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      address: json['alamat'] ?? '',
      avatar: json['avatar']?.toString(), // <--- ADDED: Parsing avatar
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': name,
    'email': email,
    'role': role,
    'nik': nik,
    'tanggal_lahir': dob,
    'jenis_kelamin': gender,
    'mobile_number': mobileNumber,
    'alamat': address,
    'avatar': avatar, // <--- ADDED
  };
}