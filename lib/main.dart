import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/experience_state.dart';
import 'screens/home_screen.dart';
import 'screens/main_shell.dart';
import 'services/push_notification_service.dart';
import 'services/firebase_service.dart';
import 'services/analytics_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  // 푸시 알림 초기화 (웹에서는 별도 처리)
  try {
    await PushNotificationService.initialize();
    // 웹에서는 토픽 구독 미지원
    if (!kIsWeb) {
      await PushNotificationService.subscribeToTopic('all_users');
    }
  } catch (e) {
    debugPrint('Push init failed: $e');
  }

  // 익명 인증
  try {
    await FirebaseService.signInAnonymously();
  } catch (e) {
    debugPrint('Auth failed: $e');
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MobileContentApp());
}

class MobileContentApp extends StatelessWidget {
  const MobileContentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExperienceState(),
      child: Consumer<ExperienceState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'AI & Stamp Mobile Content',
            debugShowCheckedModeBanner: false,
            navigatorObservers: [
              ?AnalyticsService.observer,
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C63FF),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF8F9FE),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              ),
            ),
            home: state.hasSelectedExperience
                ? const MainShell()
                : const HomeScreen(),
          );
        },
      ),
    );
  }
}
