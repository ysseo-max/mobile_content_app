import 'package:uuid/uuid.dart';
import 'firebase_service.dart';
import 'analytics_service.dart';

class CouponService {
  static const _uuid = Uuid();

  /// 로컬 캐시 (오프라인 폴백용)
  static final Set<String> _localCoupons = {};

  /// 쿠폰 생성 (스탬프 랠리 완료 시)
  static String generateCoupon() {
    final code = 'LED-${_uuid.v4().substring(0, 8).toUpperCase()}';
    _localCoupons.add(code);

    // Firestore에 비동기 저장 (실패해도 무시)
    try { FirebaseService.saveCoupon(couponCode: code, source: 'stamp_rally'); } catch (_) {}
    try { AnalyticsService.logStampCouponIssued(code); } catch (_) {}

    return code;
  }

  /// 쿠폰 유효성 검증
  /// Firestore 우선, 실패 시 로컬 캐시 폴백
  static Future<bool> validateCouponAsync(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return false;

    try {
      final serverValid =
          await FirebaseService.validateCouponFromServer(trimmed);
      if (serverValid) return true;
    } catch (_) {}

    // 로컬 폴백
    return _localCoupons.contains(trimmed);
  }

  /// 동기 검증 (로컬 캐시만, 기존 코드 호환용)
  static bool validateCoupon(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return false;
    return _localCoupons.contains(trimmed);
  }

  /// 쿠폰 사용 처리
  static void useCoupon(String code) {
    final trimmed = code.trim();
    _localCoupons.remove(trimmed);

    // Firestore에 비동기 업데이트 (실패해도 무시)
    try { FirebaseService.useCouponOnServer(trimmed); } catch (_) {}
    try { AnalyticsService.logCouponUsed(trimmed); } catch (_) {}
  }
}
