import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../models/experience_state.dart';
import '../../services/location_service.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  MobileScannerController? _scannerController;
  bool _hasScanned = false;
  bool _isCheckingLocation = true;
  bool _locationOk = false;
  bool _cameraPermissionOk = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _checkCameraPermission();
    if (_cameraPermissionOk) {
      await _checkLocation();
      if (_locationOk) {
        _scannerController = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
        );
      }
    }
    if (mounted) setState(() => _isCheckingLocation = false);
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _cameraPermissionOk = status.isGranted;
        if (!_cameraPermissionOk) {
          final lang = context.read<ExperienceState>().languageCode;
          _errorMessage = {
            'ko': '카메라 권한이 필요합니다. 설정에서 카메라 접근을 허용해 주세요.',
            'en': 'Camera permission required. Please allow camera access in settings.',
            'ja': 'カメラの許可が必要です。設定でカメラへのアクセスを許可してください。',
            'zh': '需要相机权限。请在设置中允许相机访问。',
          }[lang] ?? 'Camera permission required.';
        }
      });
    }
  }

  Future<void> _checkLocation() async {
    final result = await LocationService.checkLocationRange();
    if (mounted) {
      setState(() {
        _locationOk = result == LocationCheckResult.withinRange;
        if (!_locationOk) {
          final lang = context.read<ExperienceState>().languageCode;
          _errorMessage = LocationService.getErrorMessage(result, lang);
        }
      });
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      setState(() => _hasScanned = true);
      final state = context.read<ExperienceState>();
      state.confirmStamp(state.currentScanLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();
    final l10n = state.l10n;

    final locationLabels = ['C', 'B', 'A'];
    final currentLabel = state.currentScanLocation >= 0 &&
            state.currentScanLocation < locationLabels.length
        ? locationLabels[state.currentScanLocation]
        : '?';

    // Loading state
    if (_isCheckingLocation) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1D3E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFFF6B6B)),
              const SizedBox(height: 24),
              Text(
                l10n.tr('processing'),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Error state (camera denied or out of range)
    if (!_cameraPermissionOk || !_locationOk) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    !_cameraPermissionOk
                        ? Icons.camera_alt_outlined
                        : Icons.location_off_rounded,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _errorMessage ?? l10n.tr('error'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => state.setStampStep(1),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(l10n.tr('cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isCheckingLocation = true;
                            _errorMessage = null;
                          });
                          _initializeScreen();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(l10n.tr('retry')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Scanner view
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_scannerController != null)
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),
          // Overlay
          Container(color: Colors.black.withValues(alpha: 0.4)),
          // Scan frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFF6B6B), width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => state.setStampStep(1),
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${l10n.tr('scanQR')} - $currentLabel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          // Bottom instructions
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(Icons.qr_code_2_rounded,
                    color: Colors.white, size: 36),
                const SizedBox(height: 12),
                Text(
                  l10n.tr('scanQR'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
