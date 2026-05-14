import 'package:circle/core/constants/app_strings.dart';
import 'package:circle/core/services/gemini_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeminiService error mapping', () {
    test('maps auth, quota, model, and overload failures safely', () {
      final service = GeminiService();

      expect(
        service.messageForDioForTest(_dioError(401, 'API key invalid')),
        AppStrings.aiInvalidKey,
      );
      expect(
        service.messageForDioForTest(_dioError(429, 'Quota exceeded')),
        AppStrings.aiQuotaExceeded,
      );
      expect(
        service.messageForDioForTest(_dioError(404, 'Model not found')),
        AppStrings.aiModelUnavailable,
      );
      expect(
        service.messageForDioForTest(_dioError(503, 'Model overloaded')),
        AppStrings.aiModelOverloaded,
      );
    });
  });
}

DioException _dioError(int statusCode, String message) {
  final requestOptions = RequestOptions(path: '/models/test:generateContent');
  return DioException(
    requestOptions: requestOptions,
    response: Response<Map<String, dynamic>>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: {
        'error': {'message': message},
      },
    ),
  );
}
