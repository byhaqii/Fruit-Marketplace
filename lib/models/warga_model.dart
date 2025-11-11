class WargaModel {
  final String id;
  final String nama;

  WargaModel({required this.id, required this.nama});

  factory WargaModel.fromJson(Map<String, dynamic> json) =>
      WargaModel(id: json['id']?.toString() ?? '', nama: json['nama'] ?? '');

  Map<String, dynamic> toJson() => {'id': id, 'nama': nama};
}