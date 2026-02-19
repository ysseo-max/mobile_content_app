import 'dart:io';
import 'firebase_service.dart';
import 'analytics_service.dart';

class AiImageService {
  /// AI 이미지 생성
  /// 1. 체험 기록을 Firestore에 저장
  /// 2. AI 서버 API를 호출하여 이미지 생성 (현재는 시뮬레이션)
  static Future<String> generateImage({
    required File photo,
    required String birthYear,
    required String gender,
  }) async {
    // 1. 체험 기록 저장
    final experienceId = await FirebaseService.saveUserExperience(
      birthYear: birthYear,
      gender: gender,
    );

    // 3. AI 이미지 생성 (실제 AI API 호출 위치)
    // TODO: 실제 AI 서버 API 엔드포인트로 교체
    await Future.delayed(const Duration(seconds: 3));
    final generatedUrl =
        'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/600';

    // 4. 결과를 Firestore에 업데이트
    await FirebaseService.updateExperienceImage(
      experienceId: experienceId,
      generatedImageUrl: generatedUrl,
    );

    await AnalyticsService.logAiImageGenerated();

    // experienceId를 반환해야 하므로 URL에 인코딩 (실제로는 state에 저장)
    _lastExperienceId = experienceId;

    return generatedUrl;
  }

  static String? _lastExperienceId;
  static String? get lastExperienceId => _lastExperienceId;

  /// LED 송출
  static Future<Map<String, dynamic>> sendToLed({
    required String imageUrl,
    String paymentMethod = 'credit_card',
    String? couponCode,
  }) async {
    // Firestore에 LED 전송 기록 저장
    final transmissionId = await FirebaseService.saveLedTransmission(
      experienceId: _lastExperienceId ?? '',
      imageUrl: imageUrl,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
    );

    // TODO: 실제 LED 서버 통신으로 교체
    await Future.delayed(const Duration(seconds: 5));

    // 완료 상태 업데이트
    await FirebaseService.updateLedStatus(
      transmissionId: transmissionId,
      status: 'completed',
    );

    await AnalyticsService.logLedCompleted();

    return {
      'success': true,
      'estimatedDisplayTime': '3',
      'transmissionId': transmissionId,
    };
  }

  /// 결제 처리
  static Future<bool> processPayment({
    required String method,
    required double amount,
  }) async {
    // TODO: 실제 결제 PG 연동으로 교체
    await Future.delayed(const Duration(seconds: 2));

    // 결제 기록 Firestore 저장
    await FirebaseService.savePayment(
      experienceId: _lastExperienceId ?? '',
      method: method,
      amount: amount,
      currency: 'KRW',
    );

    await AnalyticsService.logPaymentCompleted(
      method: method,
      amount: amount,
    );

    return true;
  }
}
