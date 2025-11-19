class UserModel {
  final String id;
  final String name;
  final String email;
  final String nik;
  final String dob; 
  final String gender;
  final String mobileNumber;
  final String address;

  const UserModel({
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
    // PERBAIKAN: Cek 'nama' dulu, jika kosong cek 'name'
    name: json['nama'] ?? json['name'] ?? '', 
    email: json['email'] ?? '',
    nik: json['nik'] ?? '',
    dob: json['tanggal_lahir'] ?? '',
    gender: json['jenis_kelamin'] ?? '',
    mobileNumber: json['mobile_number'] ?? '',
    address: json['alamat'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': name,
    'email': email,
    'nik': nik,
    'tanggal_lahir': dob,
    'jenis_kelamin': gender,
    'mobile_number': mobileNumber,
    'alamat': address,
  };
}