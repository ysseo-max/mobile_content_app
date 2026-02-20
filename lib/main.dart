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

  // Firebase 초기화만 먼저 (필수)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // UI를 먼저 띄운 후 나머지 초기화 진행
  runApp(const MobileContentApp());

  // 푸시 알림, 인증 등은 UI 로드 후 비동기 실행
  _initServices();
}

/// UI 로드 후 백그라운드에서 서비스 초기화
Future<void> _initServices() async {
  // 익명 인증
  try {
    await FirebaseService.signInAnonymously();
  } catch (e) {
    debugPrint('Auth failed: $e');
  }

  // 푸시 알림 초기화
  try {
    await PushNotificationService.initialize();
    if (!kIsWeb) {
      await PushNotificationService.subscribeToTopic('all_users');
    }
  } catch (e) {
    debugPrint('Push init failed: $e');
  }
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
