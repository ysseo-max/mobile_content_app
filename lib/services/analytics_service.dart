import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static FirebaseAnalytics? _analytics;

  static FirebaseAnalytics? get _instance {
    try {
      _analytics ??= FirebaseAnalytics.instance;
      return _analytics;
    } catch (_) {
      return null;
    }
  }

  static FirebaseAnalyticsObserver? get observer {
    final instance = _instance;
    if (instance == null) return null;
    return FirebaseAnalyticsObserver(analytics: instance);
  }

  static Future<void> _log(String name,
      [Map<String, Object>? parameters]) async {
    try {
      await _instance?.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics: $e');
    }
  }

  static Future<void> logExperienceSelected(String type) =>
      _log('experience_selected', {'type': type});

  static Future<void> logAiImageRequested({
    required String birthYear,
    required String gender,
  }) =>
      _log('ai_image_requested', {'birth_year': birthYear, 'gender': gender});

  static Future<void> logAiImageGenerated() => _log('ai_image_generated');

  static Future<void> logImageSaved() => _log('image_saved');

  static Future<void> logImageShared() => _log('image_shared');

  static Future<void> logPremiumStarted() => _log('premium_started');

  static Future<void> logPaymentCompleted({
    required String method,
    required double amount,
  }) =>
      _log('payment_completed', {'method': method, 'amount': amount});

  static Future<void> logCouponUsed(String couponCode) =>
      _log('coupon_used', {'coupon_code': couponCode});

  static Future<void> logLedCompleted() => _log('led_completed');

  static Future<void> logStampCollected(String location) =>
      _log('stamp_collected', {'location': location});

  static Future<void> logStampRallyCompleted() =>
      _log('stamp_rally_completed');

  static Future<void> logStampCouponIssued(String couponCode) =>
      _log('stamp_coupon_issued', {'coupon_code': couponCode});

  static Future<void> logLanguageChanged(String langCode) =>
      _log('language_changed', {'language': langCode});
}
