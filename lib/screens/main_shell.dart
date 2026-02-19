import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/experience_state.dart';
import 'ai_experience/ai_experience_screen.dart';
import 'stamp_rally/stamp_rally_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();
    final l10n = state.l10n;

    return Scaffold(
      body: IndexedStack(
        index: state.currentTab,
        children: const [
          AiExperienceScreen(),
          StampRallyScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // Home button
                IconButton(
                  onPressed: () => state.goHome(),
                  icon: const Icon(Icons.home_rounded),
                  color: Colors.grey.shade500,
                  tooltip: l10n.tr('backToHome'),
                ),
                const SizedBox(width: 4),
                // AI Experience Tab
                Expanded(
                  child: _TabButton(
                    label: l10n.tr('aiImageExperience'),
                    icon: Icons.auto_awesome,
                    isSelected: state.currentTab == 0,
                    gradientColors: const [
                      Color(0xFF6C63FF),
                      Color(0xFF4ECDC4)
                    ],
                    onTap: () => state.setTab(0),
                  ),
                ),
                const SizedBox(width: 8),
                // Stamp Rally Tab
                Expanded(
                  child: _TabButton(
                    label: l10n.tr('stampRally'),
                    icon: Icons.confirmation_number_outlined,
                    isSelected: state.currentTab == 1,
                    gradientColors: const [
                      Color(0xFFFF6B6B),
                      Color(0xFFFFE66D)
                    ],
                    onTap: () => state.setTab(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: gradientColors)
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
