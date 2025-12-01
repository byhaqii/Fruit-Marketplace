// lib/core/services/ml_prediction_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img_lib;
// Import relatif, sesuaikan jika Anda memindahkan file logger.dart
import '../../utils/logger.dart'; 

class MlPredictionService {
  // Gunakan Interpreter? untuk penanganan inisialisasi yang lebih aman
  Interpreter? _interpreter;
  // Inisialisasi _labels dengan list kosong
  List<String> _labels = []; 
  
  // Path ke model dan label di folder assets/
  final String _modelPath = 'assets/fruit_model.tflite'; 
  final String _labelPath = 'assets/labels.txt';

  // Future yang melacak status inisialisasi model
  // Ini memastikan prediksi tidak dijalankan sebelum model dimuat
  late final Future<void> initialization; 

  MlPredictionService() {
    initialization = _loadModel();
  }

  /// Memuat model TFLite dan file label secara asinkron.
  Future<void> _loadModel() async {
    try {
      final labelsData = await rootBundle.loadString(_labelPath);
      // Membagi data label berdasarkan baris, menghapus spasi, dan memastikan tidak kosong
      _labels = labelsData.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

      _interpreter = await Interpreter.fromAsset(_modelPath);
      Logger.log('MlService', "Model ML dan label berhasil dimuat. Jumlah kelas: ${_labels.length}"); 
    } catch (e) {
      Logger.log('MlService', "Gagal memuat model ML: $e"); 
      // Penting: rethrow agar FutureBuilder di ScanPage tahu ada error serius
      rethrow;
    }
  }

  /// Melakukan inferensi (prediksi) pada gambar buah.
  Future<Map<String, dynamic>> predictFruit(String imagePath) async {
    // 1. Tunggu inisialisasi
    await initialization;
    
    // Pastikan interpreter siap sebelum digunakan
    if (_interpreter == null || _labels.isEmpty) {
      throw Exception("Model ML belum dimuat atau label hilang. Cek labels.txt dan fruit_model.tflite di folder assets/");
    }
    
    try {
      final inputImage = img_lib.decodeImage(File(imagePath).readAsBytesSync());
      if (inputImage == null) {
        throw Exception("Gagal memuat gambar dari path.");
      }

      // Ukuran input standar untuk banyak model klasifikasi
      final int inputSize = 224; 
      
      // Pra-pemrosesan Gambar (Resize)
      final resizedImage = img_lib.copyResize(inputImage, width: inputSize, height: inputSize);
      
      // Inisialisasi input tensor: [1, 224, 224, 3]
      final inputTensor = Float32List(1 * inputSize * inputSize * 3).reshape([1, inputSize, inputSize, 3]);

      // Isi input tensor dengan data piksel yang sudah dinormalisasi
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resizedImage.getPixelSafe(x, y);
          
          // Normalisasi: nilai RGB dibagi 255.0
          inputTensor[0][y][x][0] = pixel.r / 255.0; // Red
          inputTensor[0][y][x][1] = pixel.g / 255.0; // Green
          inputTensor[0][y][x][2] = pixel.b / 255.0; // Blue
        }
      }

      // 2. Siapkan Output Tensor (ukuran tergantung jumlah label/kelas)
      final outputTensor = Float32List(1 * _labels.length).reshape([1, _labels.length]);

      // 3. Jalankan Inferensi
      _interpreter!.run(inputTensor, outputTensor); 

      // 4. Pasca-pemrosesan Output (Mencari skor tertinggi/Argmax)
      double maxScore = -1;
      int maxIndex = -1;
      for (int i = 0; i < _labels.length; i++) {
        double score = outputTensor[0][i];
        if (score > maxScore) {
          maxScore = score;
          maxIndex = i;
        }
      }

      final String predictedLabel = maxIndex >= 0 ? _labels[maxIndex] : 'Tidak Dikenal';

      Logger.log('MlService', "Prediksi ML: $predictedLabel dengan confidence ${maxScore.toStringAsFixed(2)}"); 

      return {
        'label': predictedLabel,
        'confidence': maxScore,
      };
    } catch (e) {
      Logger.log('MlService', "Gagal melakukan prediksi ML: $e"); 
      // Lempar exception agar ScanPage tahu ada error dan menampilkannya.
      throw Exception('Gagal melakukan prediksi ML: $e'); 
    }
  }

  void dispose() {
    // Tutup interpreter secara aman
    _interpreter?.close(); 
  }
}