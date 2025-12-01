// lib/modules/scan/pages/scan_page.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 

// Import service yang baru/diperbarui
import '../../../core/services/ml_prediction_service.dart'; 
// Import display screen
import '../widget/displaypicture_screen.dart'; 

// Variabel global 'cameras' (asumsi diinisialisasi di main.dart)
List<CameraDescription> cameras = []; 

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // --- Camera Controller & State ---
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker(); 
  
  // Hanya ML Service (sesuai permintaan klasifikasi HSV/GLCM/SVM)
  late final MlPredictionService _mlService; 

  @override
  void initState() {
    super.initState();
    // Inisialisasi hanya ML Service
    _mlService = MlPredictionService();
    _initializeControllerFuture = _initCamera();
  }

  // Fungsi terpisah untuk inisialisasi async
  Future<void> _initCamera() async {
    try {
      List<CameraDescription> camList;
      
      // Cek apakah variabel global 'cameras' sudah diisi (dari main.dart)
      if (cameras.isNotEmpty) {
          camList = cameras;
      } else {
          // Panggil fungsi global availableCameras()
          camList = await availableCameras(); 
          if (camList.isEmpty) {
             throw Exception('Kamera tidak ditemukan.');
          }
      }
      
      final firstCamera = camList.first;
      
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );
      
      return _controller!.initialize();
    } catch (e) {
      print('Error inisialisasi kamera: $e');
      rethrow; 
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _mlService.dispose(); 
    super.dispose();
  }

  // --- FUNGSI KLASIFIKASI & NAVIGASI ---

  Future<void> _processImageAndNavigate(String imagePath) async {
    if (!mounted) return;
    setState(() {
      _isProcessing = true;
    });

    String finalDisplayResult = "Gagal mengklasifikasi buah.";
    String searchQuery = ""; 

    try {
      // Panggil ML Service untuk Klasifikasi Buah berbasis Fitur (HSV/GLCM/SVM)
      Map<String, dynamic> prediction = await _mlService.predictFruit(imagePath);
      String label = prediction['label'];
      double confidence = prediction['confidence'];

      // Klasifikasi Sukses
      searchQuery = label.toUpperCase(); 
      finalDisplayResult = "HASIL KLASIFIKASI BUAH (SVM):\nJenis: $label\nConfidence: ${(confidence * 100).toStringAsFixed(2)}%";
      
      // Navigasi ke DisplayPictureScreen
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(
              imagePath: imagePath,
              ocrResult: finalDisplayResult, // Gunakan untuk menampilkan detail ML
              searchQuery: searchQuery,      
            ),
          ),
        );
      }

    } catch (e) {
      String resultMessage = "Terjadi kesalahan saat memproses data: $e";
      _showResultDialog("Error Pemrosesan", resultMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }


  Future<void> _takePicture(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Error: Kamera tidak siap.');
      _showResultDialog("Kamera Error", "Kamera belum siap atau tidak tersedia.");
      return;
    }

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      if (!context.mounted) return;

      // Lanjutkan ke proses klasifikasi
      _processImageAndNavigate(image.path);

    } catch (e) {
      print('Terjadi kesalahan saat mengambil gambar: $e');
      _showResultDialog("Ambil Gambar Error", e.toString());
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        if (!context.mounted) return;
        // Lanjutkan ke proses klasifikasi
        _processImageAndNavigate(image.path);
      }
    } catch (e) {
      print('Terjadi kesalahan saat memilih gambar dari galeri: $e');
      _showResultDialog("Galeri Error", e.toString());
    }
  }
  
  Future<void> _showResultDialog(String title, String content) async {
    return showDialog<void>(
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
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: _buildTransparentAppBar(),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          
          if (snapshot.hasError || _controller == null) {
            // Tampilan jika kamera gagal dimuat atau tidak ada.
            return Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.error?.toString() ?? "Kamera tidak ditemukan. Gunakan tombol upload.",
                      textAlign: TextAlign.center,
                      // PERBAIKAN: Hapus duplikasi 'color'
                      style: const TextStyle(color: Colors.white), 
                    ),
                    const SizedBox(height: 30),
                    if (!_isProcessing) 
                       _buildUploadButton(context),
                    if (_isProcessing)
                      const CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!), 
                _buildUIOverlays(context),
              ],
            );
          } else {
            // Tampilan loading
            return Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          }
        },
      ),
    );
  }

  // --- UI Helper Widgets (Adaptasi dari kode Anda) ---

  AppBar _buildTransparentAppBar() {
    return AppBar(
      title: const Text('Scan'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      actions: [
        IconButton(
          icon: Icon(
            _controller != null && _controller!.value.flashMode == FlashMode.off 
              ? Icons.flash_off_outlined 
              : Icons.flash_on_outlined,
            color: Colors.white,
          ),
          onPressed: _isProcessing ? null : () {
            if (_controller != null) {
              _controller!.setFlashMode(
                _controller!.value.flashMode == FlashMode.off 
                  ? FlashMode.torch 
                  : FlashMode.off
              );
              setState(() {}); 
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.flip_camera_ios_outlined),
          onPressed: _isProcessing ? null : () {
            // TODO: Logika untuk membalik kamera
            print('Tombol putar kamera ditekan');
          },
        ),
      ],
    );
  }

  Widget _buildUIOverlays(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 20),
        const Text(
          'Scan untuk cari Produk',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(blurRadius: 10.0, color: Colors.black54)],
          ),
        ),
        _buildScanBox(),
        const Spacer(),
        _buildBottomControls(context),
      ],
    );
  }

  Widget _buildScanBox() {
    const double scanBoxSize = 280.0;
    return Container(
      width: scanBoxSize,
      height: scanBoxSize,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: _isProcessing 
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : null,
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return IconButton(
      onPressed: _isProcessing ? null : () => _pickImageFromGallery(context), 
      icon: const Icon(
        Icons.file_upload_outlined,
        color: Colors.white,
        size: 32.0,
      ),
      tooltip: 'Pilih Gambar dari Galeri',
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0).copyWith(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TOMBOL UPLOAD
          _buildUploadButton(context),
          
          // TOMBOL AMBIL FOTO
          GestureDetector(
            onTap: _isProcessing ? null : () => _takePicture(context), 
            child: Container(
              width: 70.0,
              height: 70.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _isProcessing ? Colors.grey : Colors.white, width: 5.0),
              ),
              child: Center(
                child: Container(
                  width: 54.0,
                  height: 54.0,
                  decoration: BoxDecoration(
                    color: _isProcessing ? Colors.grey : Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          
          // TOMBOL PUTAR KAMERA
          IconButton(
            onPressed: _isProcessing ? null : () {
               if (_controller != null) {
                // TODO: Logika untuk membalik kamera
                print('Tombol putar kamera ditekan');
               }
            },
            icon: const Icon(
              Icons.flip_camera_ios,
              color: Colors.white,
              size: 32.0,
            ),
            tooltip: 'Putar Kamera',
          ),
        ],
      ),
    );
  }
}