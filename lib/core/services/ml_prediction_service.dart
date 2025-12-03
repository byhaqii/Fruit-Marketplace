

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img_lib;
import '../../utils/logger.dart'; 

class MlPredictionService {

  Interpreter? _interpreter;
  List<String> _labels = []; 
  

  final String _modelPath = 'assets/fruit_model.tflite'; 
  final String _labelPath = 'assets/labels.txt';
  late final Future<void> initialization; 

  MlPredictionService() {
    initialization = _loadModel();
  }


  Future<void> _loadModel() async {
    try {
      final labelsData = await rootBundle.loadString(_labelPath);
    
      _labels = labelsData.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

      _interpreter = await Interpreter.fromAsset(_modelPath);
      Logger.log('MlService', "Model ML dan label berhasil dimuat. Jumlah kelas: ${_labels.length}"); 
    } catch (e) {
      Logger.log('MlService', "Gagal memuat model ML: $e"); 
    
      rethrow;
    }
  }


  Future<Map<String, dynamic>> predictFruit(String imagePath) async {
  
    await initialization;
    
  
    if (_interpreter == null || _labels.isEmpty) {
      throw Exception("Model ML belum dimuat atau label hilang. Cek labels.txt dan fruit_model.tflite di folder assets/");
    }
    
    try {
      final inputImage = img_lib.decodeImage(File(imagePath).readAsBytesSync());
      if (inputImage == null) {
        throw Exception("Gagal memuat gambar dari path.");
      }

    
      final int inputSize = 224; 
      
    
      final resizedImage = img_lib.copyResize(inputImage, width: inputSize, height: inputSize);
      
    
      final inputTensor = Float32List(1 * inputSize * inputSize * 3).reshape([1, inputSize, inputSize, 3]);

    
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resizedImage.getPixelSafe(x, y);
          
        
          inputTensor[0][y][x][0] = pixel.r / 255.0;
          inputTensor[0][y][x][1] = pixel.g / 255.0;
          inputTensor[0][y][x][2] = pixel.b / 255.0;
        }
      }

    
      final outputTensor = Float32List(1 * _labels.length).reshape([1, _labels.length]);

    
      _interpreter!.run(inputTensor, outputTensor); 

    
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
    
      throw Exception('Gagal melakukan prediksi ML: $e'); 
    }
  }

  void dispose() {
  
    _interpreter?.close(); 
  }
}