// lib/core/services/ml_prediction_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img_lib;
import '../../utils/logger.dart'; 

class MlPredictionService {
  late Interpreter _interpreter;
  late List<String> _labels;
  final String _modelPath = 'assets/fruit_model.tflite'; 
  final String _labelPath = 'assets/labels.txt';

  MlPredictionService() {
    _loadModel();
  }

  /// Memuat model TFLite dan file label.
  Future<void> _loadModel() async {
    try {
      final labelsData = await rootBundle.loadString(_labelPath);
      _labels = labelsData.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

      _interpreter = await Interpreter.fromAsset(_modelPath);
      Logger.log('MlService', "Model ML dan label berhasil dimuat."); 
    } catch (e) {
      Logger.log('MlService', "Gagal memuat model ML: $e"); 
      rethrow;
    }
  }

  /// Melakukan inferensi (prediksi) pada gambar buah.
  Future<Map<String, dynamic>> predictFruit(String imagePath) async {
    if (_labels == null || _labels.isEmpty) { 
        await _loadModel();
    }

    try {
      final inputImage = img_lib.decodeImage(File(imagePath).readAsBytesSync());
      if (inputImage == null) {
        throw Exception("Gagal memuat gambar dari path.");
      }

      // 1. Pra-pemrosesan Gambar (Resize & Normalisasi)
      final resizedImage = img_lib.copyResize(inputImage, width: 224, height: 224);
      final inputTensor = Float32List(1 * 224 * 224 * 3).reshape([1, 224, 224, 3]);

      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          
          // PERBAIKAN FINAL: Mengakses komponen warna Red, Green, Blue 
          // secara langsung melalui index pada objek Pixel, lalu normalisasi
          
          // Channel 0 = Red
          inputTensor[0][y][x][0] = pixel[0] / 255.0; 
          
          // Channel 1 = Green
          inputTensor[0][y][x][1] = pixel[1] / 255.0;
          
          // Channel 2 = Blue
          inputTensor[0][y][x][2] = pixel[2] / 255.0;
        }
      }

      // 2. Siapkan Output Tensor
      final outputTensor = Float32List(1 * _labels.length).reshape([1, _labels.length]);

      // 3. Jalankan Inferensi
      _interpreter.run(inputTensor, outputTensor);

      // 4. Pasca-pemrosesan Output
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
      return {'label': 'ERROR: Prediksi Gagal', 'confidence': 0.0};
    }
  }

  void dispose() {
    _interpreter.close();
  }
}