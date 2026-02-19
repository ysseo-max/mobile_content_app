import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/experience_state.dart';
import '../../widgets/gradient_button.dart';

class AiIntroScreen extends StatelessWidget {
  const AiIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();
    final l10n = state.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Icon
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                l10n.tr('aiIntroTitle'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D3E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.tr('aiIntroDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
              const Spacer(flex: 2),
              // Steps indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepIndicator(
                    icon: Icons.camera_alt_outlined,
                    label: l10n.tr('takePhoto'),
                    number: '1',
                  ),
                  _StepDivider(),
                  _StepIndicator(
                    icon: Icons.edit_outlined,
                    label: l10n.tr('birthYearHint'),
                    number: '2',
                  ),
                  _StepDivider(),
                  _StepIndicator(
                    icon: Icons.auto_awesome,
                    label: 'AI',
                    number: '3',
                  ),
                ],
              ),
              const Spacer(),
              GradientButton(
                text: l10n.tr('startExperience'),
                icon: Icons.arrow_forward_rounded,
                onPressed: () => state.setAiStep(1),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;

  const _StepIndicator({
    required this.icon,
    required this.label,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StepDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
      child: SizedBox(
        width: 32,
        child: Divider(
          color: Colors.grey.shade300,
          thickness: 2,
        ),
      ),
    );
  }
}
