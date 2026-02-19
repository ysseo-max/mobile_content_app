import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/experience_state.dart';
import 'ai_intro_screen.dart';
import 'photo_upload_screen.dart';
import 'birth_year_screen.dart';
import 'gender_screen.dart';
import 'ai_generating_screen.dart';
import 'ai_result_screen.dart';
import 'premium_intro_screen.dart';
import 'payment_screen.dart';
import 'coupon_input_screen.dart';
import 'led_waiting_screen.dart';
import 'led_complete_screen.dart';

class AiExperienceScreen extends StatelessWidget {
  const AiExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();

    return PopScope(
      canPop: state.aiStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && state.aiStep > 0) {
          _handleBack(state);
        }
      },
      child: AnimatedSwitcher(
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
      ),
    );
  }

  Widget _buildStep(ExperienceState state) {
    switch (state.aiStep) {
      case 0:
        return const AiIntroScreen(key: ValueKey('ai_intro'));
      case 1:
        return const PhotoUploadScreen(key: ValueKey('photo_upload'));
      case 2:
        return const BirthYearScreen(key: ValueKey('birth_year'));
      case 3:
        return const GenderScreen(key: ValueKey('gender'));
      case 4:
        return const AiGeneratingScreen(key: ValueKey('generating'));
      case 5:
        return const AiResultScreen(key: ValueKey('result'));
      case 6:
        return const PremiumIntroScreen(key: ValueKey('premium_intro'));
      case 7:
        return const PaymentScreen(key: ValueKey('payment'));
      case 8:
        return const CouponInputScreen(key: ValueKey('coupon_input'));
      case 9:
        return const LedWaitingScreen(key: ValueKey('led_waiting'));
      case 10:
        return const LedCompleteScreen(key: ValueKey('led_complete'));
      default:
        return const AiIntroScreen(key: ValueKey('ai_intro_default'));
    }
  }

  void _handleBack(ExperienceState state) {
    if (state.aiStep == 6) {
      state.setAiStep(5);
    } else if (state.aiStep == 8) {
      state.setAiStep(7);
    } else if (state.aiStep > 0) {
      state.setAiStep(state.aiStep - 1);
    }
  }
}
