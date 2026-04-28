import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_limits.dart';
import '../constants/app_strings.dart';

// TEMPORARY TEST IMPLEMENTATION:
// Direct Gemini calls are used only while Firebase Cloud Functions are blocked
// by the current Firebase plan. For production, remove this direct API key path
// and route AI requests back through Firebase Callable Functions.
//
// Do not hardcode the key in source. Pass it at build/run time:
// flutter run --dart-define=GEMINI_API_KEY=your_key
const _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
const _geminiModel = 'gemini-3.1-flash';
const _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1';

class GeminiService {
  GeminiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _geminiBaseUrl,
              connectTimeout: const Duration(
                seconds: AppLimits.aiTimeoutSeconds,
              ),
              receiveTimeout: const Duration(
                seconds: AppLimits.aiTimeoutSeconds,
              ),
              sendTimeout: const Duration(seconds: AppLimits.aiTimeoutSeconds),
              headers: const {'Content-Type': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<String> generateText(String prompt) async {
    final key = _geminiApiKey.trim();
    if (key.isEmpty) {
      throw const GeminiServiceException(
        'Gemini API key is not configured. Use --dart-define=GEMINI_API_KEY=...',
      );
    }

    try {
      final response = await _dio
          .post<Map<String, dynamic>>(
            '/models/$_geminiModel:generateContent',
            options: Options(headers: {'x-goog-api-key': key}),
            data: {
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 700,
                'responseMimeType': 'application/json',
              },
            },
          )
          .timeout(const Duration(seconds: AppLimits.aiTimeoutSeconds));

      final text = _extractText(response.data);
      if (text == null || text.trim().isEmpty) {
        throw const GeminiServiceException(AppStrings.aiFailed);
      }
      return text.trim();
    } on TimeoutException catch (error, stackTrace) {
      _log(error, stackTrace);
      throw const GeminiServiceException(AppStrings.aiTimeout);
    } on DioException catch (error, stackTrace) {
      _logDio(error, stackTrace);
      throw GeminiServiceException(_messageForDio(error));
    } on GeminiServiceException {
      rethrow;
    } catch (error, stackTrace) {
      _log(error, stackTrace);
      throw const GeminiServiceException(AppStrings.aiFailed);
    }
  }

  String? _extractText(Map<String, dynamic>? data) {
    final candidates = data?['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      return null;
    }

    final first = candidates.first;
    if (first is! Map) {
      return null;
    }
    final content = first['content'];
    if (content is! Map) {
      return null;
    }
    final parts = content['parts'];
    if (parts is! List) {
      return null;
    }

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map && part['text'] is String) {
        buffer.write(part['text']);
      }
    }
    return buffer.toString();
  }

  String _messageForDio(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return AppStrings.aiTimeout;
    }

    final statusCode = error.response?.statusCode;
    final apiMessage = _apiErrorMessage(error.response?.data);
    if (statusCode == 401 || statusCode == 403) {
      return apiMessage ?? 'Gemini API key is invalid or not authorized.';
    }
    if (statusCode == 404) {
      return apiMessage ?? 'Gemini model $_geminiModel was not found.';
    }
    if (statusCode == 429) {
      return 'Gemini rate limit reached. Try again later.';
    }
    return apiMessage ?? AppStrings.aiFailed;
  }

  String? _apiErrorMessage(Object? data) {
    if (data is Map) {
      final error = data['error'];
      if (error is Map && error['message'] is String) {
        return error['message'] as String;
      }
    }
    return null;
  }

  void _logDio(DioException error, StackTrace stackTrace) {
    if (!kDebugMode) {
      return;
    }
    debugPrint(
      'GeminiService request failed: '
      'status=${error.response?.statusCode}, '
      'model=$_geminiModel, '
      'message=${_apiErrorMessage(error.response?.data) ?? error.message}',
    );
    debugPrintStack(stackTrace: stackTrace, label: 'GeminiService stack');
  }

  void _log(Object error, StackTrace stackTrace) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('GeminiService error: $error');
    debugPrintStack(stackTrace: stackTrace, label: 'GeminiService stack');
  }
}

class GeminiServiceException implements Exception {
  const GeminiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
