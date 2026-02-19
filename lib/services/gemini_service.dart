import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _model = 'gemini-3-pro-image-preview';
  static const Duration _timeout = Duration(seconds: 90);

  /// API 키 — 환경변수 또는 직접 설정
  static String? _apiKey;

  static void setApiKey(String key) {
    _apiKey = key;
  }

  static String? get apiKey => _apiKey;

  /// 배경 이미지 + 사용자 사진을 합성하여 기념사진 생성
  static Future<Uint8List> compositeImage({
    required Uint8List backgroundBytes,
    required Uint8List photoBytes,
    required String birthYear,
    required String gender,
  }) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      throw GeminiException('API key not configured');
    }

    final backgroundBase64 = base64Encode(backgroundBytes);
    final photoBase64 = base64Encode(photoBytes);

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$key',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': backgroundBase64,
              },
            },
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': photoBase64,
              },
            },
            {
              'text':
                  'Composite the person from the second image into the background scene of the first image. '
                      'Make it look like a natural commemorative photo taken at this location. '
                      'The person is $gender, born in $birthYear. '
                      'Keep the person\'s appearance accurate and place them naturally in the scene. '
                      'Output only the final composited image.',
            },
          ],
        },
      ],
      'generationConfig': {
        'responseModalities': ['IMAGE'],
      },
    });

    final http.Response response;
    try {
      response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_timeout);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw GeminiException('Request timed out. Please try again.');
      }
      throw GeminiException('Network error: $e');
    }

    if (response.statusCode != 200) {
      final errorBody = _tryParseError(response.body);
      if (response.statusCode == 400 && errorBody.contains('SAFETY')) {
        throw GeminiSafetyException(
          'Content was filtered by safety settings. Please try a different photo.',
        );
      }
      throw GeminiException(
        'API error (${response.statusCode}): $errorBody',
      );
    }

    // Parse response
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      // Check for prompt feedback (safety filter)
      final promptFeedback = json['promptFeedback'] as Map<String, dynamic>?;
      if (promptFeedback != null) {
        final blockReason = promptFeedback['blockReason'] as String?;
        if (blockReason != null) {
          throw GeminiSafetyException(
            'Content was filtered: $blockReason. Please try a different photo.',
          );
        }
      }
      throw GeminiException('No image generated. Please try again.');
    }

    final candidate = candidates[0] as Map<String, dynamic>;
    final content = candidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw GeminiException('Empty response. Please try again.');
    }

    // Find image part in response (API returns camelCase keys)
    for (final part in parts) {
      final partMap = part as Map<String, dynamic>;
      final inlineData = (partMap['inlineData'] ?? partMap['inline_data'])
          as Map<String, dynamic>?;
      if (inlineData != null) {
        final imageData = (inlineData['data']) as String?;
        if (imageData != null) {
          return base64Decode(imageData);
        }
      }
    }

    throw GeminiException('No image data in response. Please try again.');
  }

  static String _tryParseError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      return error?['message'] as String? ?? body;
    } catch (_) {
      return body;
    }
  }
}

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);
  @override
  String toString() => message;
}

class GeminiSafetyException extends GeminiException {
  GeminiSafetyException(super.message);
}
