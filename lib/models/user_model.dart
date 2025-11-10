// folder models file user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String nik;
  final String dob; // Date of Birth
  final String gender;
  final String mobileNumber;
  final String address;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.nik = '',
    this.dob = '',
    this.gender = '',
    this.mobileNumber = '',
    this.address = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    // Tambahan data profil
    nik: json['nik'] ?? '',
    dob: json['dob'] ?? '',
    gender: json['gender'] ?? '',
    mobileNumber: json['mobile_number'] ?? '',
    address: json['address'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 
    'name': name, 
    'email': email,
    // Tambahan data profil
    'nik': nik,
    'dob': dob,
    'gender': gender,
    'mobile_number': mobileNumber,
    'address': address,
  };

  // Contoh data dummy untuk Profile Page
  static UserModel get dummyUser => UserModel(
    id: 'u001',
    name: 'Muhammad Rizal Al Baihaqi',
    email: 'mrizalalbainaqi@gmail.com',
    nik: '2341720225',
    dob: '12 June 2004',
    gender: 'Male',
    mobileNumber: '0822-2847-2871',
    address: 'Jl. Bareng Raya 2N 550c',
  );
}