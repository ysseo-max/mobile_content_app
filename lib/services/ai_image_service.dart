import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'firebase_service.dart';
import 'analytics_service.dart';
import 'gemini_service.dart';

class AiImageResult {
  final Uint8List imageBytes;
  final String? filePath;

  AiImageResult({required this.imageBytes, this.filePath});
}

class AiImageService {
  /// AI 이미지 생성 (Gemini API)
  /// [backgroundUrl] — 프리셋 배경 URL (customBackgroundBytes가 null일 때 사용)
  /// [customBackgroundBytes] — 사용자 갤러리에서 업로드한 배경 바이트
  static Future<AiImageResult> generateImage({
    required String backgroundUrl,
    required Uint8List photoBytes,
    required String birthYear,
    required String gender,
    Uint8List? customBackgroundBytes,
  }) async {
    // 1. 체험 기록 저장
    final experienceId = await FirebaseService.saveUserExperience(
      birthYear: birthYear,
      gender: gender,
    );

    // 2. 배경 이미지: 커스텀이면 바이트 직접 사용, 아니면 URL 다운로드
    final backgroundBytes =
        customBackgroundBytes ?? await _downloadImage(backgroundUrl);

    // 3. Gemini API로 이미지 합성
    final imageBytes = await GeminiService.compositeImage(
      backgroundBytes: backgroundBytes,
      photoBytes: photoBytes,
      birthYear: birthYear,
      gender: gender,
    );

    // 4. 임시 파일로 저장 (네이티브 플랫폼)
    String? filePath;
    if (!kIsWeb) {
      try {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/ai_composite_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await file.writeAsBytes(imageBytes);
        filePath = file.path;
      } catch (_) {
        // 파일 저장 실패해도 바이트 데이터는 사용 가능
      }
    }

    // 5. 결과를 Firestore에 업데이트
    await FirebaseService.updateExperienceImage(
      experienceId: experienceId,
      generatedImageUrl: filePath ?? 'gemini-generated',
    );

    await AnalyticsService.logAiImageGenerated();

    _lastExperienceId = experienceId;

    return AiImageResult(imageBytes: imageBytes, filePath: filePath);
  }

  static Future<Uint8List> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url)).timeout(
      const Duration(seconds: 30),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to download background image');
    }
    return response.bodyBytes;
  }

  static String? _lastExperienceId;
  static String? get lastExperienceId => _lastExperienceId;

  /// LED 송출
  static Future<Map<String, dynamic>> sendToLed({
    required String imageUrl,
    Uint8List? imageBytes,
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
