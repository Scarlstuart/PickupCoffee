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
  bool _isTorchOn = false;

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
      
      // Initialize controller with all barcode formats enabled
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        returnImage: false,
        formats: const [
          BarcodeFormat.qrCode,
          BarcodeFormat.aztec,
          BarcodeFormat.dataMatrix,
          BarcodeFormat.pdf417,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.itf,
          BarcodeFormat.codabar,
        ],
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
      // Get the first valid barcode
      for (final barcode in barcodes) {
        String? code = barcode.rawValue ?? barcode.displayValue;
        if (code != null && code.isNotEmpty) {
          setState(() {
            _isScanning = false;
          });

          // Show all scanned data information
          _showScannedData(barcode);
          return;
        }
      }
    }
  }

  void _showScannedData(Barcode barcode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pickupGreen,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      color: AppColors.pickupWhite,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'QR Code Information',
                        style: TextStyle(
                          color: AppColors.pickupWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.pickupWhite,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _isScanning = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Format', barcode.format.name.toUpperCase()),
                      const Divider(),
                      if (barcode.rawValue != null)
                        _buildInfoSection(
                          'Raw Value',
                          barcode.rawValue!,
                          isSelectable: true,
                        ),
                      if (barcode.displayValue != null &&
                          barcode.displayValue != barcode.rawValue)
                        _buildInfoSection(
                          'Display Value',
                          barcode.displayValue!,
                          isSelectable: true,
                        ),
                      const Divider(),
                      _buildInfoRow('Type', _getBarcodeTypeName(barcode.type)),
                      if (barcode.url != null) ...[
                        const Divider(),
                        _buildInfoSection(
                          'URL',
                          barcode.url!.url,
                          isSelectable: true,
                          isUrl: true,
                        ),
                        if (barcode.url!.title != null)
                          _buildInfoRow('Title', barcode.url!.title!),
                      ],
                      if (barcode.email != null) ...[
                        const Divider(),
                        _buildInfoSection(
                          'Email',
                          barcode.email!.address ?? '',
                          isSelectable: true,
                          isEmail: true,
                        ),
                        if (barcode.email!.subject != null)
                          _buildInfoRow('Subject', barcode.email!.subject!),
                        if (barcode.email!.body != null)
                          _buildInfoSection(
                            'Body',
                            barcode.email!.body!,
                            isSelectable: true,
                          ),
                      ],
                      if (barcode.phone != null) ...[
                        const Divider(),
                        _buildInfoSection(
                          'Phone',
                          barcode.phone!.number ?? '',
                          isSelectable: true,
                          isPhone: true,
                        ),
                      ],
                      if (barcode.sms != null) ...[
                        const Divider(),
                        _buildInfoSection(
                          'SMS Number',
                          barcode.sms!.phoneNumber,
                          isSelectable: true,
                        ),
                        if (barcode.sms!.message != null)
                          _buildInfoSection(
                            'Message',
                            barcode.sms!.message!,
                            isSelectable: true,
                          ),
                      ],
                      if (barcode.wifi != null) ...[
                        const Divider(),
                        _buildInfoRow('WiFi SSID', barcode.wifi!.ssid ?? ''),
                        _buildInfoRow('Password', barcode.wifi!.password ?? ''),
                        _buildInfoRow('Encryption', barcode.wifi!.encryptionType.name),
                      ],
                      if (barcode.geoPoint != null) ...[
                        const Divider(),
                        _buildInfoRow(
                          'Latitude',
                          barcode.geoPoint!.latitude.toStringAsFixed(6),
                        ),
                        _buildInfoRow(
                          'Longitude',
                          barcode.geoPoint!.longitude.toStringAsFixed(6),
                        ),
                      ],
                      if (barcode.contactInfo != null) ...[
                        const Divider(),
                        if (barcode.contactInfo!.name != null)
                          _buildInfoRow('Name', barcode.contactInfo!.name!.formattedName ?? ''),
                        if (barcode.contactInfo!.phones.isNotEmpty)
                          _buildInfoRow(
                            'Phone',
                            barcode.contactInfo!.phones.first.number ?? '',
                          ),
                        if (barcode.contactInfo!.emails.isNotEmpty)
                          _buildInfoRow(
                            'Email',
                            barcode.contactInfo!.emails.first.address ?? '',
                          ),
                        if (barcode.contactInfo!.addresses.isNotEmpty)
                          _buildInfoSection(
                            'Address',
                            barcode.contactInfo!.addresses.first.addressLines.join(', '),
                            isSelectable: true,
                          ),
                      ],
                      if (barcode.calendarEvent != null) ...[
                        const Divider(),
                        _buildInfoRow('Event Summary', barcode.calendarEvent!.summary ?? ''),
                        if (barcode.calendarEvent!.start != null)
                          _buildInfoRow(
                            'Start',
                            barcode.calendarEvent!.start.toString(),
                          ),
                        if (barcode.calendarEvent!.end != null)
                          _buildInfoRow(
                            'End',
                            barcode.calendarEvent!.end.toString(),
                          ),
                        if (barcode.calendarEvent!.location != null)
                          _buildInfoRow('Location', barcode.calendarEvent!.location!),
                        if (barcode.calendarEvent!.description != null)
                          _buildInfoSection(
                            'Description',
                            barcode.calendarEvent!.description!,
                            isSelectable: true,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pickupGreyVeryLight,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.pickupGrey,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String label,
    String value, {
    bool isSelectable = false,
    bool isUrl = false,
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.pickupGrey,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isUrl
                  ? Colors.blue
                  : isEmail
                      ? Colors.blue
                      : isPhone
                          ? Colors.blue
                          : Colors.black,
            ),
          ),
          if (isUrl && value.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                // Could open URL in browser
              },
              icon: const Icon(Icons.open_in_browser, size: 16),
              label: const Text('Open URL'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.pickupGreen,
              ),
            ),
        ],
      ),
    );
  }

  String _getBarcodeTypeName(BarcodeType type) {
    switch (type) {
      case BarcodeType.url:
        return 'URL';
      case BarcodeType.email:
        return 'Email';
      case BarcodeType.phone:
        return 'Phone';
      case BarcodeType.sms:
        return 'SMS';
      case BarcodeType.wifi:
        return 'WiFi';
      case BarcodeType.geo:
        return 'Geolocation';
      case BarcodeType.contactInfo:
        return 'Contact';
      case BarcodeType.calendarEvent:
        return 'Calendar Event';
      case BarcodeType.driverLicense:
        return 'Driver License';
      case BarcodeType.text:
        return 'Text';
      default:
        return type.name;
    }
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
          // Flashlight button
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {
                if (_controller != null) {
                  setState(() {
                    _isTorchOn = !_isTorchOn;
                  });
                  _controller!.toggleTorch();
                }
              },
              backgroundColor: _isTorchOn 
                  ? AppColors.pickupGreen 
                  : AppColors.pickupGrey.withOpacity(0.7),
              child: Icon(
                _isTorchOn ? Icons.flashlight_on : Icons.flashlight_off,
                color: AppColors.pickupWhite,
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

