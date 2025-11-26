// lib/modules/scan/pages/scan_page.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 

import '../widget/displaypicture_screen.dart'; 

// Constants
const Color primaryColor = Color(0xFF2D7F6A); 

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker(); 

  // State untuk loading OCR/ML
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initCamera();
  }

  // Fungsi terpisah untuk inisialisasi async
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      
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
    super.dispose();
  }

  // =========================================================
  // LOGIKA PEMROSESAN (ML/OCR)
  // =========================================================
  Future<void> _processImageForProduct(String imagePath, BuildContext context) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // --- Placeholder Panggilan Service ML/OCR ---
      // Target Deteksi Anda: Apel, Jeruk Bali, Peach, Tomat.
      // Anda akan mengganti kode di bawah ini dengan pemanggilan API ke service ML/OCR Anda.
      
      await Future.delayed(const Duration(seconds: 2)); // Simulasi waktu proses
      
      // Hasil Simulasi: Deteksi Tomat
      final String detectedProductName = "Tomat Ceri Grade A"; 
      final String searchResult = "Tomat"; // Query yang akan diteruskan ke halaman hasil

      if (!context.mounted) return;

      // Navigasi ke halaman hasil
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imagePath: imagePath,
            ocrResult: detectedProductName, 
            searchQuery: searchResult,     
          ),
        ),
      );

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses gambar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }


  // 1. Fungsi untuk mengambil gambar dari kamera
  Future<void> _takePicture(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Error: Kamera tidak siap.');
      return;
    }
    if (_isProcessing) return;

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      if (!context.mounted) return;

      // Lanjut ke proses OCR/ML
      _processImageForProduct(image.path, context);
      
    } catch (e) {
      print('Terjadi kesalahan saat mengambil gambar: $e');
    }
  }

  // 2. Fungsi untuk mengambil gambar dari galeri
  Future<void> _handleGalleryPick(BuildContext context) async {
    if (_isProcessing) return;
    
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null && context.mounted) {
        _processImageForProduct(image.path, context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memilih gambar dari galeri')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildTransparentAppBar(),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          
          if (snapshot.hasError) {
            return Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Gagal memuat kamera.\nPastikan Anda sudah memberi izin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
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
                if (_isProcessing) _buildProcessingOverlay(), // Loading Overlay
              ],
            );
          } else {
            return Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  // --- UI Helper Widgets ---

  // Overlay Loading saat memproses
  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: primaryColor),
              SizedBox(height: 15),
              Text("Memproses gambar (ML/OCR)...", style: TextStyle(color: primaryColor)),
            ],
          ),
        ),
      ),
    );
  }

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
          icon: const Icon(Icons.flash_on_outlined),
          onPressed: _controller != null && _controller!.value.isInitialized
            ? () {
               _controller!.setFlashMode(
                 _controller!.value.flashMode == FlashMode.off 
                   ? FlashMode.torch 
                   : FlashMode.off
               );
            } : null,
        ),
        IconButton(
          icon: const Icon(Icons.flip_camera_ios_outlined),
          onPressed: () {
            // TODO: Logika untuk membalik kamera
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
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0).copyWith(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 48), 
          // Tombol Ambil Gambar
          GestureDetector(
            onTap: _isProcessing ? null : () => _takePicture(context), 
            child: Container(
              width: 70.0,
              height: 70.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5.0),
              ),
              child: Center(
                child: Container(
                  width: 54.0,
                  height: 54.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          // Tombol Upload dari Galeri
          IconButton(
            onPressed: _isProcessing ? null : () => _handleGalleryPick(context), 
            icon: Icon(
              Icons.file_upload_outlined,
              color: _isProcessing ? Colors.grey : Colors.white,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}