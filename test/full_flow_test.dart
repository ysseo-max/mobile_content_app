import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mobile_content/models/experience_state.dart';
import 'package:mobile_content/screens/home_screen.dart';
import 'package:mobile_content/screens/main_shell.dart';
import 'package:mobile_content/screens/ai_experience/ai_intro_screen.dart';
import 'package:mobile_content/screens/ai_experience/photo_upload_screen.dart';
import 'package:mobile_content/screens/ai_experience/birth_year_screen.dart';
import 'package:mobile_content/screens/ai_experience/gender_screen.dart';
import 'package:mobile_content/screens/ai_experience/ai_result_screen.dart';
import 'package:mobile_content/screens/ai_experience/premium_intro_screen.dart';
import 'package:mobile_content/screens/ai_experience/payment_screen.dart';
import 'package:mobile_content/screens/ai_experience/coupon_input_screen.dart';
import 'package:mobile_content/screens/ai_experience/led_complete_screen.dart';
import 'package:mobile_content/screens/stamp_rally/stamp_intro_screen.dart';
import 'package:mobile_content/screens/stamp_rally/stamp_board_screen.dart';
import 'package:mobile_content/screens/stamp_rally/stamp_confirmed_screen.dart';
import 'package:mobile_content/screens/stamp_rally/reward_screen.dart';
import 'package:mobile_content/screens/stamp_rally/coupon_reward_screen.dart';
import 'package:mobile_content/services/coupon_service.dart';
import 'package:mobile_content/l10n/app_localizations.dart';
import 'package:mobile_content/main.dart';

Widget wrapWithProvider(Widget child, {ExperienceState? state}) {
  return ChangeNotifierProvider<ExperienceState>(
    create: (_) => state ?? ExperienceState(),
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('Home Screen Tests', () {
    testWidgets('Home screen renders with title and two cards',
        (tester) async {
      await tester.pumpWidget(const MobileContentApp());
      await tester.pumpAndSettle();

      // Should find the app title
      expect(find.textContaining('AI'), findsAny);
      // Should find two experience options
      expect(find.byType(GestureDetector), findsAny);
    });

    testWidgets('Language selector is present', (tester) async {
      await tester.pumpWidget(const MobileContentApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('Tapping AI card navigates to AI experience', (tester) async {
      final state = ExperienceState();
      await tester.pumpWidget(wrapWithProvider(const HomeScreen(), state: state));
      await tester.pumpAndSettle();

      // Find ExperienceCard widgets by their unique icon
      final aiCard = find.byIcon(Icons.auto_awesome);
      expect(aiCard, findsOneWidget);
      await tester.tap(aiCard);
      await tester.pumpAndSettle();

      expect(state.hasSelectedExperience, true);
      expect(state.currentTab, 0);
    });

    testWidgets('Tapping Stamp card navigates to Stamp Rally', (tester) async {
      final state = ExperienceState();
      await tester.pumpWidget(wrapWithProvider(const HomeScreen(), state: state));
      await tester.pumpAndSettle();

      final stampCard = find.byIcon(Icons.confirmation_number_outlined);
      expect(stampCard, findsOneWidget);
      await tester.tap(stampCard);
      await tester.pumpAndSettle();

      expect(state.hasSelectedExperience, true);
      expect(state.currentTab, 1);
    });
  });

  group('AI Experience Flow Tests', () {
    testWidgets('AI intro screen renders correctly', (tester) async {
      await tester.pumpWidget(wrapWithProvider(const AiIntroScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_awesome), findsAny);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('AI intro start button navigates to photo upload',
        (tester) async {
      final state = ExperienceState();
      await tester
          .pumpWidget(wrapWithProvider(const AiIntroScreen(), state: state));
      await tester.pumpAndSettle();

      // Find and tap start button
      final startBtn = find.byType(ElevatedButton);
      expect(startBtn, findsOneWidget);
      await tester.tap(startBtn);
      await tester.pumpAndSettle();

      expect(state.aiStep, 1);
    });

    testWidgets('Photo upload screen shows camera and gallery options',
        (tester) async {
      final state = ExperienceState();
      state.setAiStep(1);
      await tester
          .pumpWidget(wrapWithProvider(const PhotoUploadScreen(), state: state));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
    });

    testWidgets('Birth year screen validates input', (tester) async {
      final state = ExperienceState();
      state.setAiStep(2);
      await tester
          .pumpWidget(wrapWithProvider(const BirthYearScreen(), state: state));
      await tester.pumpAndSettle();

      // Find text field and enter valid year
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, '1990');
      await tester.pumpAndSettle();

      // Find next button and tap
      final nextBtn = find.byType(ElevatedButton);
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(state.birthYear, '1990');
      expect(state.aiStep, 3);
    });

    testWidgets('Birth year rejects invalid years', (tester) async {
      final state = ExperienceState();
      state.setAiStep(2);
      await tester
          .pumpWidget(wrapWithProvider(const BirthYearScreen(), state: state));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, '1900');
      await tester.pumpAndSettle();

      final nextBtn = find.byType(ElevatedButton);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // Should not advance (1900 < 1920)
      expect(state.aiStep, 2);
    });

    testWidgets('Gender screen allows selection', (tester) async {
      final state = ExperienceState();
      state.setAiStep(3);
      await tester
          .pumpWidget(wrapWithProvider(const GenderScreen(), state: state));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.male_rounded), findsOneWidget);
      expect(find.byIcon(Icons.female_rounded), findsOneWidget);

      // Tap male
      final maleCard = find.byIcon(Icons.male_rounded);
      await tester.tap(maleCard);
      await tester.pumpAndSettle();
      expect(state.gender, 'male');

      // Tap female
      final femaleCard = find.byIcon(Icons.female_rounded);
      await tester.tap(femaleCard);
      await tester.pumpAndSettle();
      expect(state.gender, 'female');
    });

    testWidgets('AI result screen shows action buttons', (tester) async {
      final state = ExperienceState();
      state.setAiStep(5);
      state.setGeneratedImage('https://picsum.photos/400/600');
      await tester
          .pumpWidget(wrapWithProvider(const AiResultScreen(), state: state));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('Premium intro navigates to payment', (tester) async {
      final state = ExperienceState();
      state.setAiStep(6);
      state.setGeneratedImage('https://picsum.photos/400/600');
      await tester.pumpWidget(
          wrapWithProvider(const PremiumIntroScreen(), state: state));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.tv_rounded), findsOneWidget);

      final nextBtn = find.byType(ElevatedButton);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
      expect(state.aiStep, 7);
    });

    testWidgets('Payment screen shows price and two options', (tester) async {
      final state = ExperienceState();
      state.setAiStep(7);
      await tester
          .pumpWidget(wrapWithProvider(const PaymentScreen(), state: state));
      await tester.pumpAndSettle();

      // Price display
      expect(find.text('₩5,000'), findsAny);
      // Credit card and coupon options
      expect(find.byIcon(Icons.credit_card_rounded), findsOneWidget);
      expect(find.byIcon(Icons.confirmation_number_rounded), findsOneWidget);
    });

    testWidgets('Payment coupon option navigates to coupon input',
        (tester) async {
      final state = ExperienceState();
      state.setAiStep(7);
      await tester
          .pumpWidget(wrapWithProvider(const PaymentScreen(), state: state));
      await tester.pumpAndSettle();

      // Tap coupon option (second GestureDetector)
      final couponOption = find.byIcon(Icons.confirmation_number_rounded);
      await tester.tap(couponOption);
      await tester.pumpAndSettle();

      expect(state.aiStep, 8);
    });

    testWidgets('Coupon input screen validates coupon', (tester) async {
      final state = ExperienceState();
      state.setAiStep(8);
      await tester
          .pumpWidget(wrapWithProvider(const CouponInputScreen(), state: state));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.confirmation_number_rounded), findsOneWidget);

      // Enter invalid coupon
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'INVALID');
      await tester.pumpAndSettle();

      final applyBtn = find.byType(ElevatedButton);
      await tester.tap(applyBtn);
      await tester.pumpAndSettle();

      // Should stay on step 8 (invalid coupon)
      expect(state.aiStep, 8);
    });

    testWidgets('LED complete screen shows success', (tester) async {
      final state = ExperienceState();
      state.setAiStep(10);
      await tester.pumpWidget(
          wrapWithProvider(const LedCompleteScreen(), state: state));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });
  });

  group('Stamp Rally Flow Tests', () {
    testWidgets('Stamp intro screen renders', (tester) async {
      await tester.pumpWidget(wrapWithProvider(const StampIntroScreen()));
      await tester.pumpAndSettle();

      expect(find.text('C'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('Stamp intro start button works', (tester) async {
      final state = ExperienceState();
      await tester.pumpWidget(
          wrapWithProvider(const StampIntroScreen(), state: state));
      await tester.pumpAndSettle();

      final startBtn = find.byType(ElevatedButton);
      await tester.tap(startBtn);
      await tester.pumpAndSettle();

      expect(state.stampStep, 1);
    });

    testWidgets('Stamp board shows 3 locations', (tester) async {
      final state = ExperienceState();
      state.setStampStep(1);
      await tester.pumpWidget(
          wrapWithProvider(const StampBoardScreen(), state: state));
      await tester.pumpAndSettle();

      // 3 stamp cards with QR scan buttons
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsNWidgets(3));
      expect(find.text('0 / 3'), findsOneWidget);
    });

    testWidgets('Stamp board scan button triggers scanning', (tester) async {
      final state = ExperienceState();
      state.setStampStep(1);
      await tester.pumpWidget(
          wrapWithProvider(const StampBoardScreen(), state: state));
      await tester.pumpAndSettle();

      // Tap first scan button
      final scanBtns = find.byIcon(Icons.qr_code_scanner_rounded);
      await tester.tap(scanBtns.first);
      await tester.pumpAndSettle();

      expect(state.stampStep, 2);
      expect(state.currentScanLocation, 0);
    });

    testWidgets('Stamp confirmed screen shows after scan', (tester) async {
      final state = ExperienceState();
      state.confirmStamp(0);
      await tester.pumpWidget(
          wrapWithProvider(const StampConfirmedScreen(), state: state));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Tap confirm button
      final confirmBtn = find.byType(ElevatedButton);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Should go back to board since not all stamps collected
      expect(state.stampStep, 1);
    });

    testWidgets('All stamps collected shows reward', (tester) async {
      final state = ExperienceState();
      state.confirmStamp(0);
      state.confirmStamp(1);
      state.confirmStamp(2);
      state.setStampStep(4);
      await tester.pumpWidget(
          wrapWithProvider(const RewardScreen(), state: state));
      // RewardScreen has a repeating animation, so use pump instead of pumpAndSettle
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.celebration_rounded), findsOneWidget);
    });

    testWidgets('Coupon reward screen shows coupon code', (tester) async {
      final state = ExperienceState();
      state.confirmStamp(0);
      state.confirmStamp(1);
      state.confirmStamp(2);
      state.generateRewardCoupon();
      await tester.pumpWidget(
          wrapWithProvider(const CouponRewardScreen(), state: state));
      await tester.pumpAndSettle();

      // Coupon code should be displayed
      expect(state.rewardCouponCode, isNotNull);
      expect(find.text(state.rewardCouponCode!), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.card_giftcard_rounded), findsOneWidget);
    });

    testWidgets('Stamp board reflects collected stamps', (tester) async {
      final state = ExperienceState();
      state.confirmStamp(0); // Collect C
      state.setStampStep(1);
      await tester.pumpWidget(
          wrapWithProvider(const StampBoardScreen(), state: state));
      await tester.pumpAndSettle();

      // Should show 1/3 collected
      expect(find.text('1 / 3'), findsOneWidget);
      // Only 2 scan buttons remaining (one stamp already collected)
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsNWidgets(2));
    });
  });

  group('State Management Tests', () {
    test('ExperienceState initial values are correct', () {
      final state = ExperienceState();
      expect(state.hasSelectedExperience, false);
      expect(state.currentTab, 0);
      expect(state.aiStep, 0);
      expect(state.selectedPhoto, null);
      expect(state.birthYear, '');
      expect(state.gender, '');
      expect(state.generatedImageUrl, null);
      expect(state.stampStep, 0);
      expect(state.stamps, [false, false, false]);
      expect(state.allStampsCollected, false);
      expect(state.rewardCouponCode, null);
    });

    test('selectExperience sets correct state', () {
      final state = ExperienceState();
      state.selectExperience(1);
      expect(state.hasSelectedExperience, true);
      expect(state.currentTab, 1);
    });

    test('goHome resets selection', () {
      final state = ExperienceState();
      state.selectExperience(1);
      state.goHome();
      expect(state.hasSelectedExperience, false);
    });

    test('AI flow: step navigation works', () {
      final state = ExperienceState();
      state.setAiStep(1);
      expect(state.aiStep, 1);
      state.setAiStep(5);
      expect(state.aiStep, 5);
    });

    test('AI flow: startPremiumFlow sets step 6', () {
      final state = ExperienceState();
      state.startPremiumFlow();
      expect(state.aiStep, 6);
      expect(state.isPremiumFlow, true);
    });

    test('AI flow: resetAiExperience clears all', () {
      final state = ExperienceState();
      state.setAiStep(5);
      state.setGender('male');
      state.setBirthYear('1990');
      state.setGeneratedImage('url');
      state.resetAiExperience();
      expect(state.aiStep, 0);
      expect(state.gender, '');
      expect(state.birthYear, '');
      expect(state.generatedImageUrl, null);
    });

    test('Stamp: confirmStamp marks correct location', () {
      final state = ExperienceState();
      state.confirmStamp(0);
      expect(state.stamps[0], true);
      expect(state.stamps[1], false);
      expect(state.stamps[2], false);
    });

    test('Stamp: allStampsCollected works', () {
      final state = ExperienceState();
      expect(state.allStampsCollected, false);
      state.confirmStamp(0);
      state.confirmStamp(1);
      state.confirmStamp(2);
      expect(state.allStampsCollected, true);
    });

    test('Stamp: checkAllStamps routes to reward when complete', () {
      final state = ExperienceState();
      state.confirmStamp(0);
      state.confirmStamp(1);
      state.confirmStamp(2);
      state.checkAllStamps();
      expect(state.stampStep, 4);
    });

    test('Stamp: checkAllStamps routes to board when incomplete', () {
      final state = ExperienceState();
      state.confirmStamp(0);
      state.checkAllStamps();
      expect(state.stampStep, 1);
    });

    test('Stamp: generateRewardCoupon creates code', () {
      final state = ExperienceState();
      state.generateRewardCoupon();
      expect(state.rewardCouponCode, isNotNull);
      expect(state.rewardCouponCode!.startsWith('LED-'), true);
      expect(state.stampStep, 5);
    });

    test('Stamp: resetStampRally clears all', () {
      final state = ExperienceState();
      state.confirmStamp(0);
      state.confirmStamp(1);
      state.generateRewardCoupon();
      state.resetStampRally();
      expect(state.stamps, [false, false, false]);
      expect(state.rewardCouponCode, null);
      expect(state.stampStep, 0);
    });
  });

  group('Coupon Service Tests', () {
    test('generateCoupon creates valid coupon', () {
      final code = CouponService.generateCoupon();
      expect(code.startsWith('LED-'), true);
      expect(code.length, greaterThan(4));
    });

    test('validateCoupon returns true for generated coupon', () {
      final code = CouponService.generateCoupon();
      expect(CouponService.validateCoupon(code), true);
    });

    test('validateCoupon returns false for invalid code', () {
      expect(CouponService.validateCoupon('INVALID'), false);
      expect(CouponService.validateCoupon(''), false);
      expect(CouponService.validateCoupon('  '), false);
    });

    test('useCoupon invalidates coupon', () {
      final code = CouponService.generateCoupon();
      expect(CouponService.validateCoupon(code), true);
      CouponService.useCoupon(code);
      expect(CouponService.validateCoupon(code), false);
    });

    test('Stamp coupon can be used in AI experience', () {
      // Generate coupon from stamp rally
      final state = ExperienceState();
      state.confirmStamp(0);
      state.confirmStamp(1);
      state.confirmStamp(2);
      state.generateRewardCoupon();
      final couponCode = state.rewardCouponCode!;

      // Use in AI experience
      final aiState = ExperienceState();
      aiState.setAiStep(8);
      aiState.setAiCouponCode(couponCode);
      expect(aiState.validateCoupon(), true);

      aiState.applyCoupon();
      expect(aiState.couponApplied, true);
      expect(aiState.aiStep, 9); // Goes to LED waiting
    });
  });

  group('Localization Tests', () {
    test('Korean translations exist', () {
      final l10n = AppLocalizations.of('ko');
      expect(l10n.tr('appTitle'), contains('모바일'));
      expect(l10n.tr('aiImageExperience'), contains('AI'));
      expect(l10n.tr('stampRally'), contains('스탬프'));
    });

    test('English translations exist', () {
      final l10n = AppLocalizations.of('en');
      expect(l10n.tr('appTitle'), contains('Mobile Content'));
      expect(l10n.tr('aiImageExperience'), contains('AI'));
      expect(l10n.tr('stampRally'), contains('Stamp'));
    });

    test('Japanese translations exist', () {
      final l10n = AppLocalizations.of('ja');
      expect(l10n.tr('appTitle'), contains('モバイル'));
      expect(l10n.tr('stampRally'), contains('スタンプ'));
    });

    test('Chinese translations exist', () {
      final l10n = AppLocalizations.of('zh');
      expect(l10n.tr('appTitle'), contains('移动'));
      expect(l10n.tr('stampRally'), contains('集章'));
    });

    test('Unknown language falls back to English', () {
      final l10n = AppLocalizations.of('fr');
      expect(l10n.tr('appTitle'), contains('Mobile Content'));
    });

    test('Unknown key returns key itself', () {
      final l10n = AppLocalizations.of('en');
      expect(l10n.tr('nonExistentKey'), 'nonExistentKey');
    });
  });

  group('Navigation Integration Tests', () {
    testWidgets('MainShell shows bottom tabs', (tester) async {
      final state = ExperienceState();
      state.selectExperience(0);
      await tester
          .pumpWidget(wrapWithProvider(const MainShell(), state: state));
      await tester.pumpAndSettle();

      // Home button
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      // Two tab labels
      expect(find.byIcon(Icons.auto_awesome), findsAny);
      expect(find.byIcon(Icons.confirmation_number_outlined), findsAny);
    });

    testWidgets('Tab switching works', (tester) async {
      final state = ExperienceState();
      state.selectExperience(0);
      await tester
          .pumpWidget(wrapWithProvider(const MainShell(), state: state));
      await tester.pumpAndSettle();

      expect(state.currentTab, 0);

      // Tap stamp rally tab
      final stampTab = find.byIcon(Icons.confirmation_number_outlined);
      await tester.tap(stampTab.last);
      await tester.pumpAndSettle();

      expect(state.currentTab, 1);
    });

    testWidgets('Home button goes back to home', (tester) async {
      final state = ExperienceState();
      state.selectExperience(0);
      await tester
          .pumpWidget(wrapWithProvider(const MainShell(), state: state));
      await tester.pumpAndSettle();

      final homeBtn = find.byIcon(Icons.home_rounded);
      await tester.tap(homeBtn);
      await tester.pumpAndSettle();

      expect(state.hasSelectedExperience, false);
    });
  });
}
