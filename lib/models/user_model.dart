// folder lib folder models file user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String nik;
  final String dob; // Menggunakan 'tanggal_lahir' dari seeder
  final String gender; // Menggunakan 'jenis_kelamin' dari seeder
  final String mobileNumber; // Tidak ada di seeder, tetap sebagai placeholder
  final String address; // Menggunakan 'alamat' dari seeder

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
    name: json['nama'] ?? '', // Menggunakan 'nama' dari seeder
    email: json['email'] ?? '',
    nik: json['nik'] ?? '',
    dob: json['tanggal_lahir'] ?? '', // Menggunakan 'tanggal_lahir'
    gender: json['jenis_kelamin'] ?? '', // Menggunakan 'jenis_kelamin'
    mobileNumber: json['mobile_number'] ?? '', // Placeholder
    address: json['alamat'] ?? '', // Menggunakan 'alamat'
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': name, // Perubahan ke 'nama'
    'email': email,
    'nik': nik,
    'tanggal_lahir': dob, // Perubahan ke 'tanggal_lahir'
    'jenis_kelamin': gender, // Perubahan ke 'jenis_kelamin'
    'mobile_number': mobileNumber,
    'alamat': address, // Perubahan ke 'alamat'
  };

  static UserModel get simulatedApiUser {
    return const UserModel(
      id: '1', // user_id dari seeder
      name: 'Warga Biasa',
      email: 'warga@jawarapintar.com',
      nik: '3201010101000001',
      dob: '1990-01-01', // Format YYYY-MM-DD
      gender: 'Laki-laki',
      mobileNumber: '0812-3456-7890', // Nomor acak/simulasi
      address: 'Jalan Kebahagiaan No. 1',
    );
  }
}