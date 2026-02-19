import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/experience_state.dart';
import '../widgets/experience_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();
    final l10n = state.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Language selector
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _LanguageSelector(
                    currentLang: state.languageCode,
                    onChanged: (lang) => state.setLanguage(lang),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                l10n.tr('appTitle'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D3E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tr('selectExperience'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),
              // AI Image Experience Card
              ExperienceCard(
                title: l10n.tr('aiImageExperience'),
                description: l10n.tr('aiIntroDesc'),
                icon: Icons.auto_awesome,
                gradientColors: const [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                onTap: () => state.selectExperience(0),
              ),
              const SizedBox(height: 20),
              // Stamp Rally Card
              ExperienceCard(
                title: l10n.tr('stampRally'),
                description: l10n.tr('stampIntroDesc'),
                icon: Icons.confirmation_number_outlined,
                gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                onTap: () => state.selectExperience(1),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String currentLang;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({
    required this.currentLang,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final languages = {
      'ko': '한국어',
      'en': 'English',
      'ja': '日本語',
      'zh': '中文',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLang,
          icon: const Icon(Icons.language, size: 20),
          style: const TextStyle(
            color: Color(0xFF1A1D3E),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: languages.entries
              .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
