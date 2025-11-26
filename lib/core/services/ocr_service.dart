// lib/core/services/ocr_service.dart

import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// Perbaikan 1: Menggunakan impor relatif yang lebih aman untuk logger internal
import '../../utils/logger.dart'; 

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Melakukan proses OCR pada file gambar yang diberikan.
  Future<String> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      // Perbaikan 2: Menggunakan metode statis Logger.log(tag, message)
      Logger.log('OcrService', "Memulai proses OCR untuk: $imagePath"); 

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String rawText = recognizedText.text;
      Logger.log('OcrService', "Teks Mentah Hasil OCR:\n$rawText"); // Perbaikan 2

      // --- Logika Pasca-pemrosesan Teks ---
      String cleanText = _postProcessOcrText(rawText);
      Logger.log('OcrService', "Teks Bersih: $cleanText"); // Perbaikan 2

      return cleanText;
    } catch (e) {
      // Perbaikan 2: Menggunakan Logger.log tanpa parameter error/stackTrace
      Logger.log('OcrService', "Gagal melakukan OCR: $e"); 
      return "ERROR: Gagal memproses gambar ($e)";
    }
  }

  /// Membersihkan dan mengekstrak informasi relevan.
  String _postProcessOcrText(String rawText) {
    String processedText = rawText.toLowerCase().trim();
    processedText = processedText.replaceAll(RegExp(r'[^\w\s\./-]', unicode: true), ' ');

    RegExp priceRegex = RegExp(r'(rp\s*(\d{1,3}(?:\.\d{3})*(?:,\d{2})?))', caseSensitive: false);
    
    if (priceRegex.hasMatch(processedText)) {
      processedText = processedText.replaceAll(priceRegex, '').trim();
    }
    
    List<String> lines = processedText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    if (lines.isNotEmpty) {
      return lines.first.toUpperCase();
    }

    return processedText.toUpperCase();
  }

  void dispose() {
    _textRecognizer.close();
  }
}