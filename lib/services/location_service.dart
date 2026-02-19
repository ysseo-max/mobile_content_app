import 'dart:math';
import 'package:geolocator/geolocator.dart';

enum LocationCheckResult {
  withinRange,
  outOfRange,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class LocationService {
  // Target location (venue center) - configurable
  static const double targetLat = 37.5665; // Example: Seoul City Hall
  static const double targetLng = 126.9780;
  static const double maxDistance = 300.0; // meters

  static Future<LocationCheckResult> checkLocationRange() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return LocationCheckResult.serviceDisabled;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationCheckResult.permissionDenied;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationCheckResult.permissionDeniedForever;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      double distance = _calculateDistance(
        position.latitude,
        position.longitude,
        targetLat,
        targetLng,
      );

      return distance <= maxDistance
          ? LocationCheckResult.withinRange
          : LocationCheckResult.outOfRange;
    } catch (e) {
      return LocationCheckResult.error;
    }
  }

  static String getErrorMessage(LocationCheckResult result, String langCode) {
    switch (result) {
      case LocationCheckResult.serviceDisabled:
        return _msgs['serviceDisabled']?[langCode] ??
            _msgs['serviceDisabled']!['en']!;
      case LocationCheckResult.permissionDenied:
        return _msgs['permissionDenied']?[langCode] ??
            _msgs['permissionDenied']!['en']!;
      case LocationCheckResult.permissionDeniedForever:
        return _msgs['permissionDeniedForever']?[langCode] ??
            _msgs['permissionDeniedForever']!['en']!;
      case LocationCheckResult.outOfRange:
        return _msgs['outOfRange']?[langCode] ??
            _msgs['outOfRange']!['en']!;
      case LocationCheckResult.error:
        return _msgs['error']?[langCode] ?? _msgs['error']!['en']!;
      case LocationCheckResult.withinRange:
        return '';
    }
  }

  static final Map<String, Map<String, String>> _msgs = {
    'serviceDisabled': {
      'ko': 'GPS가 꺼져 있습니다. 설정에서 위치 서비스를 켜주세요.',
      'en': 'GPS is disabled. Please enable location services in settings.',
      'ja': 'GPSが無効です。設定で位置情報サービスを有効にしてください。',
      'zh': 'GPS已关闭。请在设置中开启位置服务。',
    },
    'permissionDenied': {
      'ko': '위치 권한이 거부되었습니다. 권한을 허용해 주세요.',
      'en': 'Location permission denied. Please allow location access.',
      'ja': '位置情報の許可が拒否されました。許可してください。',
      'zh': '位置权限被拒绝。请允许位置访问。',
    },
    'permissionDeniedForever': {
      'ko': '위치 권한이 영구 거부되었습니다. 앱 설정에서 변경해 주세요.',
      'en':
          'Location permission permanently denied. Please change in app settings.',
      'ja': '位置情報の許可が永久に拒否されました。アプリ設定で変更してください。',
      'zh': '位置权限被永久拒绝。请在应用设置中更改。',
    },
    'outOfRange': {
      'ko': '현장 반경 300m 밖에 있습니다. 현장 가까이 이동해 주세요.',
      'en': 'You are outside the 300m venue range. Please move closer.',
      'ja': '会場の半径300m外にいます。近くに移動してください。',
      'zh': '您在场地300米范围之外。请靠近场地。',
    },
    'error': {
      'ko': '위치 확인에 실패했습니다. GPS를 확인해 주세요.',
      'en': 'Location check failed. Please check your GPS.',
      'ja': '位置確認に失敗しました。GPSを確認してください。',
      'zh': '位置确认失败。请检查GPS。',
    },
  };

  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    double dLat = _toRad(lat2 - lat1);
    double dLon = _toRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double deg) => deg * (pi / 180);
}
