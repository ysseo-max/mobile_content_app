import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/experience_state.dart';
import 'stamp_intro_screen.dart';
import 'stamp_board_screen.dart';
import 'qr_scan_screen.dart';
import 'stamp_confirmed_screen.dart';
import 'reward_screen.dart';
import 'coupon_reward_screen.dart';

class StampRallyScreen extends StatelessWidget {
  const StampRallyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
      child: _buildStep(state),
    );
  }

  Widget _buildStep(ExperienceState state) {
    switch (state.stampStep) {
      case 0:
        return const StampIntroScreen(key: ValueKey('stamp_intro'));
      case 1:
        return const StampBoardScreen(key: ValueKey('stamp_board'));
      case 2:
        return const QrScanScreen(key: ValueKey('qr_scan'));
      case 3:
        return const StampConfirmedScreen(key: ValueKey('stamp_confirmed'));
      case 4:
        return const RewardScreen(key: ValueKey('reward'));
      case 5:
        return const CouponRewardScreen(key: ValueKey('coupon_reward'));
      default:
        return const StampIntroScreen(key: ValueKey('stamp_intro_default'));
    }
  }
}
