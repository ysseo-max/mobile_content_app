import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/experience_state.dart';
import '../../widgets/gradient_button.dart';

class StampConfirmedScreen extends StatefulWidget {
  const StampConfirmedScreen({super.key});

  @override
  State<StampConfirmedScreen> createState() => _StampConfirmedScreenState();
}

class _StampConfirmedScreenState extends State<StampConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
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

    final locationNames = [
      l10n.tr('locationC'),
      l10n.tr('locationB'),
      l10n.tr('locationA'),
    ];
    final locationColors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFF9F43),
      const Color(0xFFFFE66D),
    ];

    final index = state.currentScanLocation;
    final name =
        index >= 0 && index < locationNames.length ? locationNames[index] : '';
    final color = index >= 0 && index < locationColors.length
        ? locationColors[index]
        : const Color(0xFFFF6B6B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Stamp animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                l10n.tr('stampCollected'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D3E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$name - ${l10n.tr('stampCollectedDesc')}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              GradientButton(
                text: l10n.tr('confirm'),
                icon: Icons.arrow_forward_rounded,
                colors: [color, color.withValues(alpha: 0.8)],
                onPressed: () => state.checkAllStamps(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
