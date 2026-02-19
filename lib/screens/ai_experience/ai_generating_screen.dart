import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/experience_state.dart';
import '../../services/ai_image_service.dart';

class AiGeneratingScreen extends StatefulWidget {
  const AiGeneratingScreen({super.key});

  @override
  State<AiGeneratingScreen> createState() => _AiGeneratingScreenState();
}

class _AiGeneratingScreenState extends State<AiGeneratingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  bool _hasFailed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _generateImage();
  }

  Future<void> _generateImage() async {
    setState(() {
      _hasFailed = false;
      _errorMessage = null;
    });

    final state = context.read<ExperienceState>();

    if (state.selectedPhoto == null) {
      if (mounted) {
        setState(() {
          _hasFailed = true;
          _errorMessage = state.l10n.tr('error');
        });
      }
      return;
    }

    try {
      final imageUrl = await AiImageService.generateImage(
        photo: state.selectedPhoto!,
        birthYear: state.birthYear,
        gender: state.gender,
      );

      if (mounted) {
        state.setGeneratedImage(imageUrl);
        state.setAiStep(5);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasFailed = true;
          _errorMessage = state.l10n.tr('error');
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();
    final l10n = state.l10n;

    // Error state
    if (_hasFailed) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1D3E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.shade400.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline_rounded,
                      size: 48, color: Colors.white),
                ),
                const SizedBox(height: 32),
                Text(
                  _errorMessage ?? l10n.tr('error'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => state.setAiStep(3),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
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
                        onPressed: _generateImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
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

    // Loading state
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D3E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateController.value * 6.28,
                  child: child,
                );
              },
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.15);
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF6C63FF).withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              l10n.tr('generating'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.tr('generatingDesc'),
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF4ECDC4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
