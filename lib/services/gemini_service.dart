import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiBaseUrl = 'https://rebeauty-photos.linaphotos.com/api';
  static const Duration _timeout = Duration(seconds: 120);

  /// 배경 이미지 + 사용자 사진을 서버 API를 통해 합성
  static Future<Uint8List> compositeImage({
    required Uint8List backgroundBytes,
    required Uint8List photoBytes,
    required String birthYear,
    required String gender,
  }) async {
    final url = Uri.parse('$_apiBaseUrl/generate.php');

    final request = http.MultipartRequest('POST', url)
      ..fields['birthYear'] = birthYear
      ..fields['gender'] = gender
      ..files.add(http.MultipartFile.fromBytes(
        'background',
        backgroundBytes,
        filename: 'background.jpg',
      ))
      ..files.add(http.MultipartFile.fromBytes(
        'photo',
        photoBytes,
        filename: 'photo.jpg',
      ));

    final http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await request.send().timeout(_timeout);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw GeminiException('Request timed out. Please try again.');
      }
      throw GeminiException('Network error: $e');
    }

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final errorBody = _tryParseError(response.body);
      if (response.statusCode == 422 && errorBody.contains('safety_filter')) {
        throw GeminiSafetyException(
          'Content was filtered by safety settings. Please try a different photo.',
        );
      }
      throw GeminiException(
        'API error (${response.statusCode}): $errorBody',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['success'] != true || json['image'] == null) {
      throw GeminiException('No image generated. Please try again.');
    }

    return base64Decode(json['image'] as String);
  }

  static String _tryParseError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['message'] as String? ?? json['error'] as String? ?? body;
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
