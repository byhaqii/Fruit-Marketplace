// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // <-- Tambahkan field role
  final String nik;
  final String dob; 
  final String gender;
  final String mobileNumber;
  final String address;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role, // <-- Wajib diisi
    this.nik = '',
    this.dob = '',
    this.gender = '',
    this.mobileNumber = '',
    this.address = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      // Cek 'nama' dulu, jika kosong cek 'name'
      name: json['nama'] ?? json['name'] ?? 'No Name', 
      email: json['email'] ?? '',
      // Ambil role dari json, default ke 'pembeli' jika kosong
      role: json['role']?.toString() ?? 'pembeli', 
      nik: json['nik'] ?? '',
      dob: json['tanggal_lahir'] ?? '',
      gender: json['jenis_kelamin'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      address: json['alamat'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': name,
    'email': email,
    'role': role, // <-- Sertakan saat convert ke JSON
    'nik': nik,
    'tanggal_lahir': dob,
    'jenis_kelamin': gender,
    'mobile_number': mobileNumber,
    'alamat': address,
  };
}