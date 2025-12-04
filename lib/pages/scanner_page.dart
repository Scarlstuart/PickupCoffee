import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/colors.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  MobileScannerController? _controller;
  bool _isScanning = true;
  bool _hasPermission = false;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      
      // Initialize controller
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        returnImage: false,
      );
      
      // Start the scanner
      try {
        await _controller!.start();
        setState(() {
          _isInitialized = true;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to start camera: $e';
        });
      }
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _errorMessage = 'Camera permission is permanently denied. Please enable it in settings.';
      });
    } else {
      setState(() {
        _errorMessage = 'Camera permission denied. Please grant permission to use the scanner.';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() {
          _isScanning = false;
        });

        // Show scanned data
        _showScannedData(code);
      }
    }
  }

  void _showScannedData(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scanned Information:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              data,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
              });
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pickupYellow,
              foregroundColor: AppColors.pickupGrey,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: AppColors.pickupGreen,
        foregroundColor: AppColors.pickupWhite,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show error message if permission denied or camera failed
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: AppColors.pickupGreyLight,
              ),
              const SizedBox(height: 24),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.pickupGrey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_errorMessage!.contains('permanently denied')) {
                    openAppSettings();
                  } else {
                    setState(() {
                      _errorMessage = null;
                    });
                    _initializeCamera();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pickupGreen,
                  foregroundColor: AppColors.pickupWhite,
                ),
                child: Text(
                  _errorMessage!.contains('permanently denied')
                      ? 'Open Settings'
                      : 'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading while initializing
    if (!_hasPermission || !_isInitialized || _controller == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.pickupGrey),
            ),
            const SizedBox(height: 16),
            const Text('Initializing camera...'),
          ],
        ),
      );
    }

    // Show camera view constrained to box
    const double boxSize = 280;
    return Container(
      color: AppColors.pickupGrey.withOpacity(0.9),
      child: Stack(
        children: [
          // Camera view constrained to box
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: boxSize,
                height: boxSize,
                child: MobileScanner(
                  controller: _controller!,
                  onDetect: _handleBarcode,
                  errorBuilder: (context, error, child) {
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 40,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Camera Error',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Border frame around scanning area
          Center(
            child: Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.pickupGreen,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: AppColors.pickupGrey.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Position the QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.pickupWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Toggle camera button
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                _controller?.switchCamera();
              },
              backgroundColor: AppColors.pickupYellow,
              child: const Icon(Icons.flip_camera_ios, color: AppColors.pickupGrey),
            ),
          ),
        ],
      ),
    );
  }
}

