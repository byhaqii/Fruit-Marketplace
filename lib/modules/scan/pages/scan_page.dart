// lib/modules/scan/pages/scan_page.dart

import 'package:flutter/material.dart'; // Memperbaiki extends_non_class (StatefulWidget, State, setState)
import 'package:camera/camera.dart'; // Untuk fungsionalitas kamera (sudah ada di pubspec)
import 'dart:io'; // Untuk File

// Memperbaiki "Target of URI doesn't exist" dengan impor relatif:
// Lokasi file ini: lib/modules/scan/pages/
// Lokasi service: lib/core/services/
import '../../../core/services/ocr_service.dart'; 
import '../../../core/services/ml_prediction_service.dart'; 

// Asumsi: Anda memiliki variabel global untuk kamera yang tersedia
List<CameraDescription> cameras = [];

class ScanPage extends StatefulWidget {
  // Jika Anda menerima argumen, tambahkan di sini.
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // Memperbaiki "Undefined name '_isProcessing'"
  bool _isProcessing = false;
  
  // Memperbaiki "Undefined class 'OcrService'" dan "Undefined class 'MlPredictionService'"
  late final OcrService _ocrService;
  late final MlPredictionService _mlService;

  @override
  void initState() {
    super.initState();
    _ocrService = OcrService();
    _mlService = MlPredictionService();
    // Anda mungkin perlu menambahkan inisialisasi controller kamera di sini
  }

  // --- Fungsi Proses Gambar ---
  Future<void> _processScannedImage(String imagePath, bool isLabel) async {
    // Memperbaiki "The method 'setState' isn't defined"
    setState(() {
      _isProcessing = true;
    });
    
    String resultMessage = "";

    try {
      if (isLabel) {
        // Mode OCR (Memindai Label Harga/Nama)
        String result = await _ocrService.recognizeText(imagePath);
        resultMessage = "Hasil OCR Label: $result";
        
      } else {
        // Mode ML (Memindai Buah)
        Map<String, dynamic> prediction = await _mlService.predictFruit(imagePath);
        String label = prediction['label'];
        double confidence = prediction['confidence'];

        resultMessage = "Hasil Prediksi Buah (ML):\nJenis: $label\nConfidence: ${(confidence * 100).toStringAsFixed(2)}%";
      }
      
      _showResultDialog("Hasil Pemrosesan", resultMessage);

    } catch (e) {
      resultMessage = "Terjadi kesalahan saat memproses data: $e";
      _showResultDialog("Error", resultMessage);
    } finally {
      // Memperbaiki "The method 'setState' isn't defined"
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  // --- Fungsi Pembantu UI ---
  void _showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Buah & Label'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Tampilkan UI kamera di sini
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              const Text("Kamera siap untuk memindai..."),
            
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : () {
                // TODO: Ganti dengan path gambar yang diambil dari kamera
                final dummyImagePath = File('path/ke/gambar/dummy_label.jpg').path; 
                _processScannedImage(dummyImagePath, true); // True untuk mode OCR
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Pindai Label (OCR)"),
            ),
            
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : () {
                // TODO: Ganti dengan path gambar yang diambil dari kamera
                final dummyImagePath = File('path/ke/gambar/dummy_buah.jpg').path; 
                _processScannedImage(dummyImagePath, false); // False untuk mode ML
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("Pindai Buah (ML)"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _mlService.dispose();
    // Memperbaiki "The method 'dispose' isn't defined in a superclass"
    super.dispose(); 
  }
}