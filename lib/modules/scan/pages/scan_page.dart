// lib/modules/scan/pages/scan_page.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widget/displaypicture_screen.dart'; 

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // UBAH 1: Jadikan controller nullable (?)
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Memulai inisialisasi kamera
    _initializeControllerFuture = _initCamera();
  }

  // Fungsi terpisah untuk inisialisasi async
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      
      // Inisialisasi controller
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );
      
      // Kembalikan Future initialize
      return _controller!.initialize();
    } catch (e) {
      print('Error inisialisasi kamera: $e');
      // UBAH 2: Lempar error agar FutureBuilder bisa menangkapnya
      rethrow; 
    }
  }

  @override
  void dispose() {
    // UBAH 3: Gunakan safe call (?.) 
    // Ini akan memanggil dispose() HANYA jika _controller tidak null
    _controller?.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil gambar
  Future<void> _takePicture(BuildContext context) async {
    // UBAH 4: Tambahkan pengecekan null
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Error: Kamera tidak siap.');
      return;
    }

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      if (!context.mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imagePath: image.path, 
          ),
        ),
      );
    } catch (e) {
      print('Terjadi kesalahan saat mengambil gambar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PERBAIKAN DISINI:
      // resizeToAvoidBottomInset: false mencegah layout berubah ukuran (naik)
      // saat keyboard muncul (misalnya saat fitur search aktif).
      resizeToAvoidBottomInset: false,
      
      extendBodyBehindAppBar: true,
      appBar: _buildTransparentAppBar(),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          
          // UBAH 5: Tambahkan penanganan error
          if (snapshot.hasError) {
            return Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  'Gagal memuat kamera.\nPastikan Anda sudah memberi izin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          // Jika kamera siap (dan tidak error)
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // UBAH 6: Gunakan null-check operator (!)
                CameraPreview(_controller!), 
                _buildUIOverlays(context),
              ],
            );
          } else {
            // Tampilan loading
            return Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  // --- UI Helper Widgets (Tidak berubah) ---

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
          onPressed: () {
             _controller?.setFlashMode(
               _controller!.value.flashMode == FlashMode.off 
                 ? FlashMode.torch 
                 : FlashMode.off
             );
          },
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
          GestureDetector(
            onTap: () => _takePicture(context), 
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
          IconButton(
            onPressed: () {
              // TODO: Logika untuk upload gambar dari galeri
            },
            icon: const Icon(
              Icons.file_upload_outlined,
              color: Colors.white,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}