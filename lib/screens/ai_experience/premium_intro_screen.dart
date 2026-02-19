import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/experience_state.dart';
import '../../widgets/gradient_button.dart';

class PremiumIntroScreen extends StatelessWidget {
  const PremiumIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();
    final l10n = state.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D3E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Back button
              Row(
                children: [
                  IconButton(
                    onPressed: () => state.setAiStep(5),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              // Premium icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.tv_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                l10n.tr('premiumExperience'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.tr('premiumDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.6,
                ),
              ),
              const Spacer(flex: 1),
              // Features
              _FeatureRow(
                icon: Icons.hd_rounded,
                text: 'LED',
              ),
              const SizedBox(height: 12),
              _FeatureRow(
                icon: Icons.schedule_rounded,
                text: l10n.tr('estimatedTime'),
              ),
              const Spacer(flex: 2),
              GradientButton(
                text: l10n.tr('next'),
                icon: Icons.arrow_forward_rounded,
                colors: const [Color(0xFFFFD700), Color(0xFFFF8C00)],
                onPressed: () => state.setAiStep(7),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 24),
          const SizedBox(width: 14),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
