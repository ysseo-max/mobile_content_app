import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/experience_state.dart';
import '../../services/ai_image_service.dart';
import '../../services/location_service.dart';

class LedWaitingScreen extends StatefulWidget {
  const LedWaitingScreen({super.key});

  @override
  State<LedWaitingScreen> createState() => _LedWaitingScreenState();
}

class _LedWaitingScreenState extends State<LedWaitingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _estimatedTime = '';
  bool _isChecking = true;
  bool _hasFailed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _checkLocationAndSend();
  }

  Future<void> _checkLocationAndSend() async {
    setState(() {
      _isChecking = true;
      _hasFailed = false;
      _errorMessage = null;
    });

    final state = context.read<ExperienceState>();

    // GPS range check
    final locationResult = await LocationService.checkLocationRange();
    if (locationResult != LocationCheckResult.withinRange) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _hasFailed = true;
          _errorMessage =
              LocationService.getErrorMessage(locationResult, state.languageCode);
        });
      }
      return;
    }

    // Send to LED
    try {
      if (state.generatedImageUrl == null || state.generatedImageUrl!.isEmpty) {
        throw Exception('No image to send');
      }

      final result = await AiImageService.sendToLed(
        imageUrl: state.generatedImageUrl!,
      );

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _estimatedTime = result['estimatedDisplayTime']?.toString() ?? '';
            _isChecking = false;
          });
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) state.setAiStep(10);
        } else {
          setState(() {
            _isChecking = false;
            _hasFailed = true;
            _errorMessage = state.l10n.tr('error');
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _hasFailed = true;
          _errorMessage = state.l10n.tr('error');
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();
    final l10n = state.l10n;

    // Error / out of range state
    if (_hasFailed) {
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
                  child: Icon(Icons.error_outline_rounded,
                      size: 48, color: Colors.red.shade400),
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
                        onPressed: () => state.setAiStep(5),
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
                        onPressed: _checkLocationAndSend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
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

    // Loading / transmitting state
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D3E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFFD700).withValues(
                            alpha: 0.3 + (_controller.value * 0.3),
                          ),
                          blurRadius: 20 + (_controller.value * 20),
                          spreadRadius: _controller.value * 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.tv_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              Text(
                _isChecking
                    ? l10n.tr('processing')
                    : l10n.tr('ledTransmitting'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              if (_estimatedTime.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${l10n.tr('estimatedTime')}: $_estimatedTime ${l10n.tr('minutes')}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              const SizedBox(height: 48),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFD700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
