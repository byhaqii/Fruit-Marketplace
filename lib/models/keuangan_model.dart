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

  // Data dummy untuk 'Expenses List'
  // Pastikan path 'assets/banana.png' ada di pubspec.yaml Anda
  static final List<KeuanganModel> dummyExpenses = [
    KeuanganModel(
      title: 'Organic Bananas',
      transactions: '10 Transoction', // Typo 'Transoction' disamakan dengan gambar
      amount: 'Rp55.000',
      imageAsset: 'assets/banana.png',
    ),
    KeuanganModel(
      title: 'Organic Bananas',
      transactions: '10 Transoction',
      amount: 'Rp55.000',
      imageAsset: 'assets/banana.png',
    ),
    KeuanganModel(
      title: 'Organic Bananas',
      transactions: '10 Transoction',
      amount: 'Rp55.000',
      imageAsset: 'assets/banana.png',
    ),
    KeuanganModel(
      title: 'Organic Bananas',
      transactions: '10 Transoction',
      amount: 'Rp55.000',
      imageAsset: 'assets/banana.png',
    ),
  ];
}