import 'dart:io';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';
import '../services/coupon_service.dart';
import '../services/firebase_service.dart';
import '../services/analytics_service.dart';
import 'background_item.dart';

class ExperienceState extends ChangeNotifier {
  // Language
  String _languageCode = AppLocalizations.detectLanguage();
  String get languageCode => _languageCode;
  AppLocalizations get l10n => AppLocalizations.of(_languageCode);

  void setLanguage(String code) {
    _languageCode = code;
    try { AnalyticsService.logLanguageChanged(code); } catch (_) {}
    notifyListeners();
  }

  // Tab navigation
  int _currentTab = 0; // 0 = AI, 1 = Stamp
  int get currentTab => _currentTab;
  void setTab(int tab) {
    _currentTab = tab;
    notifyListeners();
  }

  // Whether user has selected an experience from home
  bool _hasSelectedExperience = false;
  bool get hasSelectedExperience => _hasSelectedExperience;
  void selectExperience(int tab) {
    _hasSelectedExperience = true;
    _currentTab = tab;
    try { AnalyticsService.logExperienceSelected(tab == 0 ? 'ai_image' : 'stamp_rally'); } catch (_) {}
    notifyListeners();
  }

  void goHome() {
    _hasSelectedExperience = false;
    notifyListeners();
  }

  // ===================== AI Experience State =====================
  // Steps: 0=intro, 1=backgroundSelect, 2=photo, 3=birthYear, 4=gender,
  //        5=generating, 6=result, 7=premiumIntro, 8=payment, 9=coupon,
  //        10=ledWaiting, 11=ledComplete
  int _aiStep = 0;
  int get aiStep => _aiStep;

  BackgroundItem? _selectedBackground;
  BackgroundItem? get selectedBackground => _selectedBackground;

  Uint8List? _customBackgroundBytes;
  Uint8List? get customBackgroundBytes => _customBackgroundBytes;

  File? _selectedPhoto;
  File? get selectedPhoto => _selectedPhoto;

  Uint8List? _selectedPhotoBytes;
  Uint8List? get selectedPhotoBytes => _selectedPhotoBytes;

  String _birthYear = '';
  String get birthYear => _birthYear;

  String _gender = ''; // 'male' or 'female'
  String get gender => _gender;

  String? _generatedImageUrl;
  String? get generatedImageUrl => _generatedImageUrl;

  Uint8List? _generatedImageBytes;
  Uint8List? get generatedImageBytes => _generatedImageBytes;

  String? _generatedImagePath;
  String? get generatedImagePath => _generatedImagePath;

  bool _isPremiumFlow = false;
  bool get isPremiumFlow => _isPremiumFlow;

  String _couponCode = '';
  String get couponCode => _couponCode;

  bool _couponApplied = false;
  bool get couponApplied => _couponApplied;

  void setAiStep(int step) {
    _aiStep = step;
    notifyListeners();
  }

  void setSelectedBackground(BackgroundItem? bg) {
    _selectedBackground = bg;
    notifyListeners();
  }

  void setCustomBackgroundBytes(Uint8List? bytes) {
    _customBackgroundBytes = bytes;
    notifyListeners();
  }

  void setPhoto(File? photo) {
    _selectedPhoto = photo;
    notifyListeners();
  }

  void setPhotoBytes(Uint8List? bytes) {
    _selectedPhotoBytes = bytes;
    notifyListeners();
  }

  void setBirthYear(String year) {
    _birthYear = year;
  }

  void setGender(String g) {
    _gender = g;
    notifyListeners();
  }

  void setGeneratedImage(String? url) {
    _generatedImageUrl = url;
    notifyListeners();
  }

  void setGeneratedImageBytes(Uint8List? bytes) {
    _generatedImageBytes = bytes;
    notifyListeners();
  }

  void setGeneratedImagePath(String? path) {
    _generatedImagePath = path;
  }

  void startPremiumFlow() {
    _isPremiumFlow = true;
    _aiStep = 7;
    try { AnalyticsService.logPremiumStarted(); } catch (_) {}
    notifyListeners();
  }

  void setAiCouponCode(String code) {
    _couponCode = code;
  }

  void applyCoupon() {
    if (CouponService.validateCoupon(_couponCode)) {
      _couponApplied = true;
      CouponService.useCoupon(_couponCode);
      _aiStep = 10;
      notifyListeners();
    }
  }

  bool validateCoupon() {
    return CouponService.validateCoupon(_couponCode);
  }

  void resetAiExperience() {
    _aiStep = 0;
    _selectedBackground = null;
    _customBackgroundBytes = null;
    _selectedPhoto = null;
    _selectedPhotoBytes = null;
    _birthYear = '';
    _gender = '';
    _generatedImageUrl = null;
    _generatedImageBytes = null;
    _generatedImagePath = null;
    _isPremiumFlow = false;
    _couponCode = '';
    _couponApplied = false;
    notifyListeners();
  }

  // ===================== Stamp Rally State =====================
  // Steps: 0=intro, 1=board, 2=scanning, 3=confirmed, 4=reward, 5=coupon
  int _stampStep = 0;
  int get stampStep => _stampStep;

  final List<bool> _stamps = [false, false, false]; // C, B, A
  List<bool> get stamps => List.unmodifiable(_stamps);

  int _currentScanLocation = -1;
  int get currentScanLocation => _currentScanLocation;

  String? _rewardCouponCode;
  String? get rewardCouponCode => _rewardCouponCode;

  String? _stampSessionId;
  String? get stampSessionId => _stampSessionId;

  bool get allStampsCollected => _stamps.every((s) => s);

  static const _locationLabels = ['C', 'B', 'A'];

  void setStampStep(int step) {
    _stampStep = step;
    notifyListeners();
  }

  void startScan(int locationIndex) {
    _currentScanLocation = locationIndex;
    _stampStep = 2;
    notifyListeners();
  }

  Future<void> confirmStamp(int locationIndex) async {
    if (locationIndex >= 0 && locationIndex < _stamps.length) {
      _stamps[locationIndex] = true;
      _currentScanLocation = locationIndex;
      _stampStep = 3;
      notifyListeners();

      // Firestore에 스탬프 기록 (실패해도 UI에는 영향 없음)
      try {
        _stampSessionId ??= await FirebaseService.createStampSession();
        final label = _locationLabels[locationIndex];
        await FirebaseService.collectStamp(
          sessionId: _stampSessionId!,
          location: label,
        );
        AnalyticsService.logStampCollected(label);
      } catch (_) {
        // Firebase 미초기화 시 무시 (오프라인 지원)
      }
    }
  }

  void checkAllStamps() {
    if (allStampsCollected) {
      _stampStep = 4;
      try { AnalyticsService.logStampRallyCompleted(); } catch (_) {}
    } else {
      _stampStep = 1;
    }
    notifyListeners();
  }

  Future<void> generateRewardCoupon() async {
    _rewardCouponCode = CouponService.generateCoupon();
    _stampStep = 5;
    notifyListeners();

    // Firestore에 완료 기록 (실패해도 UI에는 영향 없음)
    try {
      if (_stampSessionId != null) {
        await FirebaseService.completeStampSession(
          sessionId: _stampSessionId!,
          couponCode: _rewardCouponCode!,
        );
      }
    } catch (_) {
      // Firebase 미초기화 시 무시
    }
  }

  void resetStampRally() {
    _stampStep = 0;
    _stamps.fillRange(0, _stamps.length, false);
    _currentScanLocation = -1;
    _rewardCouponCode = null;
    _stampSessionId = null;
    notifyListeners();
  }
}
