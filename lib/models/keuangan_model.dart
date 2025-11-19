// lib/models/keuangan_model.dart

class KeuanganModel {
  final String title;
  final String transactions;
  final String amount;
  final String imageAsset;

  const KeuanganModel({
    required this.title,
    required this.transactions,
    required this.amount,
    required this.imageAsset,
  });
}