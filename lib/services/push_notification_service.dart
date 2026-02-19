import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 백그라운드 메시지 핸들러 (top-level function이어야 함)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.notification?.title}');
}

class PushNotificationService {
  static FirebaseMessaging? _messagingInstance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static FirebaseMessaging? get _messaging {
    try {
      _messagingInstance ??= FirebaseMessaging.instance;
      return _messagingInstance;
    } catch (_) {
      return null;
    }
  }

  /// Android 알림 채널
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'mobile_content_high',
    'Mobile Content Notifications',
    description: 'AI 이미지 체험 및 스탬프 랠리 알림',
    importance: Importance.high,
  );

  /// 초기화
  static Future<void> initialize() async {
    try {
      final messaging = _messaging;
      if (messaging == null) {
        debugPrint('PushNotificationService: Firebase not available');
        return;
      }

      // 백그라운드 핸들러 등록
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 권한 요청
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('Push permission: ${settings.authorizationStatus}');

      // 로컬 알림 초기화
      await _initLocalNotifications();

      // Android 채널 생성
      if (!kIsWeb && Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }

      // 포그라운드 메시지 처리
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 앱이 백그라운드에서 열릴 때
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // 앱이 종료 상태에서 열릴 때
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // FCM 토큰 저장
      await _saveToken();

      // 토큰 갱신 리스너
      messaging.onTokenRefresh.listen((token) {
        _saveTokenToFirestore(token);
      });
    } catch (e) {
      debugPrint('PushNotificationService.initialize: $e');
    }
  }

  /// 로컬 알림 초기화
  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
  }

  /// 포그라운드 메시지 처리 (로컬 알림으로 표시)
  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['type'],
    );
  }

  /// 알림 탭으로 앱 열릴 때
  static void _handleMessageOpenedApp(RemoteMessage message) {
    final type = message.data['type'];
    debugPrint('Opened app from notification: $type');
  }

  /// FCM 토큰 가져오기
  static Future<String?> getToken() async {
    try {
      return await _messaging?.getToken();
    } catch (e) {
      debugPrint('PushNotificationService.getToken: $e');
      return null;
    }
  }

  /// FCM 토큰 저장
  static Future<void> _saveToken() async {
    final token = await getToken();
    if (token != null) {
      await _saveTokenToFirestore(token);
    }
  }

  /// Firestore에 토큰 저장
  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('fcm_tokens')
          .doc(token)
          .set({
        'token': token,
        'platform': kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios'),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  /// 특정 토픽 구독
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging?.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('PushNotificationService.subscribeToTopic: $e');
    }
  }

  /// 토픽 구독 해제
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging?.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('PushNotificationService.unsubscribeFromTopic: $e');
    }
  }
}
