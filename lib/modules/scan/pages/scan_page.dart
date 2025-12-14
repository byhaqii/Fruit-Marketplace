// lib/modules/scan/pages/scan_page.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import service yang baru/diperbarui
import '../../../core/services/ml_prediction_service.dart';
// Import display screen
import '../widget/displaypicture_screen.dart';

// Variabel global
List<CameraDescription> cameras = [];

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  // --- Camera Controller & State ---
  CameraController? _controller;
  CameraDescription? _currentDescription;
  late Future<void> _initializeControllerFuture;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  // Hanya ML Service
  late final MlPredictionService _mlService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mlService = MlPredictionService();
    _initializeControllerFuture = _initCamera();
  }

  // --- FUNGSI UTAMA INISIALISASI KAMERA ---
  Future<void> _initCamera([CameraDescription? cameraDescription]) async {
    try {
      // 0. Safety: Jangan lanjut jika widget sudah dispose
      if (!mounted) return;

      // 1. Pastikan daftar kamera terisi
      if (cameras.isEmpty) {
        cameras = await availableCameras();
      }
      if (cameras.isEmpty) return;

      // 2. Pilih kamera (Parameter -> Tersimpan -> Default)
      final CameraDescription cameraToUse =
          cameraDescription ?? _currentDescription ?? cameras.first;

      // Simpan kamera yang sedang dipakai
      _currentDescription = cameraToUse;

      // 3. PENTING: Matikan controller lama dengan aman
      if (_controller != null) {
        // Simpan referensi controller lama
        final CameraController oldController = _controller!;

        // Putuskan hubungan controller dari State SEBELUM dispose
        // agar UI tidak mencoba merender kamera yang sedang dimatikan.
        _controller = null;
        if (mounted) {
          setState(() {}); // Memicu rebuild ke tampilan loading
        }

        // Baru lakukan dispose pada referensi lama
        try {
          await oldController.dispose();
        } catch (e) {
          print('Error saat dispose controller lama: $e');
        }
      }

      // 4. Cek lagi apakah masih mounted sebelum buat controller baru
      if (!mounted) return;

      // Buat controller baru
      final CameraController newController = CameraController(
        cameraToUse,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _controller = newController;

      // 5. Inisialisasi
      await newController.initialize();

      // 6. Cek mounted lagi sebelum setState
      if (!mounted) {
        // Widget sudah dispose, dispose controller yg baru juga
        await newController.dispose();
        _controller = null;
        return;
      }

      // Update UI setelah siap
      setState(() {});
    } catch (e) {
      print('Error inisialisasi kamera: $e');
      if (mounted && _controller != null) {
        try {
          await _controller?.dispose();
          _controller = null;
        } catch (_) {}
        setState(() {});
      }
    }
  }

  // --- LOGIKA SWITCH CAMERA ---
  Future<void> _switchCamera() async {
    // Cek ketersediaan kamera
    if (cameras.isEmpty) {
      cameras = await availableCameras();
    }
    if (cameras.isEmpty || cameras.length < 2) {
      _showResultDialog("Info", "Hanya satu kamera yang terdeteksi.");
      return;
    }

    if (_controller == null) return;

    // Cari index kamera saat ini dan tentukan kamera berikutnya
    int currentCameraIndex = cameras.indexOf(_controller!.description);
    if (currentCameraIndex == -1) currentCameraIndex = 0;

    final int nextCameraIndex = (currentCameraIndex + 1) % cameras.length;
    final CameraDescription newCamera = cameras[nextCameraIndex];

    setState(() {
      _isProcessing = true;
    });

    try {
      // Panggil _initCamera dengan kamera baru
      // Logika dispose yang aman sudah ada di dalam _initCamera
      _initializeControllerFuture = _initCamera(newCamera);
      await _initializeControllerFuture;
    } catch (e) {
      print("Gagal ganti kamera: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // --- LIFECYCLE MANAGEMENT ---

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _mlService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App Inactive/Background -> Matikan Kamera
    if (state == AppLifecycleState.inactive) {
      if (cameraController != null) {
        cameraController.dispose();
        _controller = null; // Set null agar UI aman
        if (mounted) setState(() {});
      }
    }
    // App Resumed -> Nyalakan Kamera Kembali
    else if (state == AppLifecycleState.resumed) {
      if (_controller == null) {
        _initializeControllerFuture = _initCamera(_currentDescription);
      }
    }
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
      Map<String, dynamic> prediction = await _mlService.predictFruit(
        imagePath,
      );
      String label = prediction['label'];
      double confidence = prediction['confidence'];

      searchQuery = label.toUpperCase();
      finalDisplayResult =
          "Jenis: $label\nConfidence: ${(confidence * 100).toStringAsFixed(2)}%";

      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(
              imagePath: imagePath,
              ocrResult: finalDisplayResult,
              searchQuery: searchQuery,
            ),
          ),
        );
      }
    } catch (e) {
      _showResultDialog("Error Pemrosesan", "Terjadi kesalahan: $e");
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
      _showResultDialog("Kamera Error", "Kamera belum siap.");
      return;
    }
    if (_controller!.value.isTakingPicture) return;

    try {
      // Pastikan Future selesai sebelum ambil gambar
      await _initializeControllerFuture;

      final image = await _controller!.takePicture();
      if (!context.mounted) return;
      _processImageAndNavigate(image.path);
    } catch (e) {
      print('Terjadi kesalahan saat mengambil gambar: $e');
      _showResultDialog("Error", "Gagal mengambil gambar.");
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (!context.mounted) return;
        _processImageAndNavigate(image.path);
      }
    } catch (e) {
      print('Error galeri: $e');
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
              onPressed: () => Navigator.of(context).pop(),
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
          // Cek apakah controller siap. Jika null atau belum init, tampilkan loading.
          if (snapshot.connectionState != ConnectionState.done ||
              _controller == null ||
              !_controller!.value.isInitialized) {
            return Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          if (snapshot.hasError) {
            return Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  "Kamera tidak tersedia.\n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          // Tampilan Kamera Full Screen
          return Stack(
            fit: StackFit.expand,
            children: [
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.previewSize!.height,
                    height: _controller!.value.previewSize!.width,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
              _buildUIOverlays(context),
            ],
          );
        },
      ),
    );
  }

  // --- UI Helper Widgets ---

  AppBar _buildTransparentAppBar() {
    return AppBar(
      title: const Text('Scan'),
      automaticallyImplyLeading: false, // Hilangkan tombol Back
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      actions: [
        IconButton(
          icon: Icon(
            _controller != null && _controller!.value.flashMode == FlashMode.off
                ? Icons.flash_off_outlined
                : Icons.flash_on_outlined,
            color: Colors.white,
          ),
          onPressed:
              _isProcessing ||
                  _controller == null ||
                  !_controller!.value.isInitialized
              ? null
              : () {
                  if (_controller != null) {
                    try {
                      _controller!.setFlashMode(
                        _controller!.value.flashMode == FlashMode.off
                            ? FlashMode.torch
                            : FlashMode.off,
                      );
                      setState(() {});
                    } catch (e) {
                      print("Error flash: $e");
                    }
                  }
                },
        ),
      ],
    );
  }

  Widget _buildUIOverlays(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: kToolbarHeight + MediaQuery.of(context).padding.top + 20,
        ),
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
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 3.0),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 40.0,
      ).copyWith(bottom: 40.0),
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
                border: Border.all(
                  color: _isProcessing ? Colors.grey : Colors.white,
                  width: 5.0,
                ),
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

          // TOMBOL SWITCH KAMERA
          IconButton(
            onPressed: _isProcessing ? null : _switchCamera,
            icon: const Icon(
              Icons.flip_camera_ios,
              color: Colors.white,
              size: 32.0,
            ),
            tooltip: 'Ganti Kamera',
          ),
        ],
      ),
    );
  }
}
