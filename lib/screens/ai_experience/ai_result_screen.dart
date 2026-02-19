import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/experience_state.dart';
import '../../widgets/gradient_button.dart';

class AiResultScreen extends StatelessWidget {
  const AiResultScreen({super.key});

  Future<void> _saveImage(BuildContext context) async {
    final state = context.read<ExperienceState>();
    final l10n = state.l10n;
    final bytes = state.generatedImageBytes;
    if (bytes == null) return;

    try {
      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/ai_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await file.writeAsBytes(bytes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.tr('saveImage')}: ${file.path}'),
              backgroundColor: const Color(0xFF4ECDC4),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.tr('saveImage')),
              backgroundColor: const Color(0xFF4ECDC4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.l10n.tr('error')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    final state = context.read<ExperienceState>();
    final bytes = state.generatedImageBytes;

    try {
      if (bytes != null && !kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/ai_share_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Check out my AI image!',
        );
        return;
      }
    } catch (_) {}
    await Share.share('Check out my AI image!');
  }

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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.tr('aiImageReady'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D3E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Generated image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF6C63FF).withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: state.generatedImageBytes != null
                        ? Image.memory(
                            state.generatedImageBytes!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                        : _buildPlaceholder(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.download_rounded,
                      label: l10n.tr('saveImage'),
                      color: const Color(0xFF4ECDC4),
                      onTap: () => _saveImage(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.share_rounded,
                      label: l10n.tr('shareImage'),
                      color: const Color(0xFF6C63FF),
                      onTap: () => _shareImage(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: l10n.tr('premiumExperience'),
                icon: Icons.star_rounded,
                colors: const [Color(0xFFFFD700), Color(0xFFFF8C00)],
                onPressed: () => state.startPremiumFlow(),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  state.resetAiExperience();
                  state.goHome();
                },
                child: Text(
                  l10n.tr('backToHome'),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
      child: const Center(
        child: Icon(Icons.auto_awesome, size: 80, color: Color(0xFF6C63FF)),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
