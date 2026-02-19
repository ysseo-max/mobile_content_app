import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/experience_state.dart';
import '../../widgets/gradient_button.dart';

class StampBoardScreen extends StatelessWidget {
  const StampBoardScreen({super.key});

  static const _locationNames = ['locationC', 'locationB', 'locationA'];
  static const _locationLabels = ['C', 'B', 'A'];
  static const _locationColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFF9F43),
    Color(0xFFFFE66D),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();
    final l10n = state.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1D3E)),
          onPressed: () => state.setStampStep(0),
        ),
        title: Text(
          l10n.tr('stampBoard'),
          style: const TextStyle(
            color: Color(0xFF1A1D3E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Progress indicator
              _ProgressBar(stamps: state.stamps),
              const SizedBox(height: 32),
              // Stamp cards
              Expanded(
                child: ListView.separated(
                  itemCount: 3,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final isCollected = state.stamps[index];
                    return _StampCard(
                      label: _locationLabels[index],
                      name: l10n.tr(_locationNames[index]),
                      color: _locationColors[index],
                      isCollected: isCollected,
                      statusText: isCollected
                          ? l10n.tr('collected')
                          : l10n.tr('notCollected'),
                      scanText: l10n.tr('scanQR'),
                      onScan: isCollected
                          ? null
                          : () => state.startScan(index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (state.allStampsCollected)
                GradientButton(
                  text: l10n.tr('getCoupon'),
                  icon: Icons.card_giftcard_rounded,
                  colors: const [Color(0xFFFF6B6B), Color(0xFFFF9F43)],
                  onPressed: () => state.setStampStep(4),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final List<bool> stamps;

  const _ProgressBar({required this.stamps});

  @override
  Widget build(BuildContext context) {
    final collected = stamps.where((s) => s).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isCollected = stamps[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCollected
                        ? const Color(0xFFFF6B6B)
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    boxShadow: isCollected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B)
                                  .withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isCollected
                        ? Icons.check_rounded
                        : Icons.circle_outlined,
                    color: isCollected ? Colors.white : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            '$collected / 3',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: collected == 3
                  ? const Color(0xFFFF6B6B)
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StampCard extends StatelessWidget {
  final String label;
  final String name;
  final Color color;
  final bool isCollected;
  final String statusText;
  final String scanText;
  final VoidCallback? onScan;

  const _StampCard({
    required this.label,
    required this.name,
    required this.color,
    required this.isCollected,
    required this.statusText,
    required this.scanText,
    this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCollected
              ? color.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isCollected
                ? color.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Location indicator
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isCollected
                  ? color
                  : color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCollected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 28)
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isCollected
                        ? const Color(0xFF1A1D3E)
                        : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isCollected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: isCollected ? color : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isCollected ? color : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Scan button
          if (!isCollected)
            GestureDetector(
              onTap: onScan,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner_rounded,
                        color: color, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      scanText,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
