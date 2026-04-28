import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../constants/app_limits.dart';
import '../constants/app_strings.dart';
import 'gemini_service.dart';

class AiService {
  const AiService({required GeminiService geminiService, required Box cacheBox})
    : _geminiService = geminiService,
      _cacheBox = cacheBox;

  final GeminiService _geminiService;
  final Box _cacheBox;

  Future<String> generateMoodPost(String mood) async {
    final trimmed = _validateText(mood, maxLength: AppLimits.aiMoodMaxChars);
    final data = await _callCached('generateMoodPost', {'mood': trimmed}, () {
      return _generateJson(
        "Turn this mood into one concise social post. "
        "Return JSON only: {\"text\":\"...\"}. "
        "No markdown. Mood: $trimmed",
      );
    });
    return data['text'] as String? ?? '';
  }

  Future<List<String>> generateSmartReply({
    required String commentText,
    List<String> context = const [],
  }) async {
    final trimmed = _validateText(
      commentText,
      maxLength: AppLimits.aiCommentMaxChars,
    );
    final data = await _callCached(
      'generateSmartReply',
      {'commentText': trimmed, 'context': context.take(5).toList()},
      () {
        final contextText = context.take(5).join(' | ');
        return _generateJson(
          "Suggest exactly three short, friendly replies to this comment. "
          "Return JSON only: {\"suggestions\":[\"...\",\"...\",\"...\"]}. "
          "No markdown. Context: $contextText\nComment: $trimmed",
        );
      },
    );
    return _stringList(data['suggestions']).take(3).toList();
  }

  Future<List<AiToneVariant>> generateToneVariants(String draft) async {
    final trimmed = _validateText(draft, maxLength: AppLimits.aiDraftMaxChars);
    final data = await _callCached('generateToneVariants', {'draft': trimmed}, () {
      return _generateJson(
        "Rewrite this social post draft into three tone variants: "
        "Professional, Funny, Emotional. "
        "Return JSON only: {\"variants\":[{\"tone\":\"Professional\",\"text\":\"...\"},"
        "{\"tone\":\"Funny\",\"text\":\"...\"},{\"tone\":\"Emotional\",\"text\":\"...\"}]}. "
        "No markdown. Draft: $trimmed",
      );
    });
    final variants = data['variants'];
    if (variants is! List) {
      return const [];
    }
    return [
      for (final item in variants)
        if (item is Map)
          AiToneVariant(
            tone: item['tone']?.toString() ?? '',
            text: item['text']?.toString() ?? '',
          ),
    ].where((variant) => variant.text.isNotEmpty).take(3).toList();
  }

  Future<List<String>> summarizeFeed(List<String> posts) async {
    final cleaned = posts
        .map((post) => post.trim())
        .where((post) => post.isNotEmpty)
        .map((post) {
          if (post.length <= AppLimits.aiFeedSummaryPostMaxChars) {
            return post;
          }
          return post.substring(0, AppLimits.aiFeedSummaryPostMaxChars);
        })
        .take(AppLimits.aiFeedSummaryPostCount)
        .toList();
    if (cleaned.isEmpty) {
      throw const AiServiceException(AppStrings.aiNoFeedPosts);
    }

    final data = await _callCached('summarizeFeed', {'posts': cleaned}, () {
      final postsText = cleaned
          .asMap()
          .entries
          .map((entry) => '${entry.key + 1}. ${entry.value}')
          .join('\n');
      return _generateJson(
        "Summarize these recent social feed posts into up to five short bullets. "
        "Return JSON only: {\"summary\":[\"...\",\"...\"]}. No markdown. "
        "Posts: $postsText",
      );
    });
    return _stringList(data['summary']).take(5).toList();
  }

  Future<Map<String, dynamic>> _callCached(
    String functionName,
    Map<String, Object?> payload,
    Future<Map<String, dynamic>> Function() request,
  ) async {
    final cacheKey = _cacheKey(functionName, payload);
    final cached = _readCache(cacheKey);
    if (cached != null) {
      return cached;
    }

    try {
      final data = await request();
      await _writeCache(cacheKey, data);
      return data;
    } on TimeoutException catch (error, stackTrace) {
      _log(error, stackTrace);
      throw const AiServiceException(AppStrings.aiTimeout);
    } on GeminiServiceException catch (error, stackTrace) {
      _log(error, stackTrace);
      throw AiServiceException(error.message);
    } catch (error, stackTrace) {
      _log(error, stackTrace);
      throw const AiServiceException(AppStrings.aiFailed);
    }
  }

  Future<Map<String, dynamic>> _generateJson(String prompt) async {
    final text = await _geminiService.generateText(prompt);
    return _parseJson(text);
  }

  Map<String, dynamic>? _readCache(String key) {
    final value = _cacheBox.get(key);
    if (value is! Map) {
      return null;
    }
    final createdAt = value['createdAt'];
    final data = value['data'];
    if (createdAt is! int || data is! Map) {
      return null;
    }
    final age = DateTime.now().millisecondsSinceEpoch - createdAt;
    if (age > AppLimits.aiCacheTtl.inMilliseconds) {
      unawaited(_cacheBox.delete(key));
      return null;
    }
    debugPrint('AiService cache hit key=$key');
    return _mapFrom(data);
  }

  Future<void> _writeCache(String key, Map<String, dynamic> data) {
    return _cacheBox.put(key, {
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    });
  }

  String _validateText(String value, {required int maxLength}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const AiServiceException(AppStrings.aiInputRequired);
    }
    if (trimmed.length > maxLength) {
      throw const AiServiceException(AppStrings.aiInputTooLong);
    }
    return trimmed;
  }

  Map<String, dynamic> _mapFrom(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries) entry.key.toString(): entry.value,
      };
    }
    return const {};
  }

  Map<String, dynamic> _parseJson(String value) {
    final text = value.trim();
    try {
      return _mapFrom(jsonDecode(text));
    } catch (error) {
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (match == null) {
        throw const AiServiceException(AppStrings.aiFailed);
      }
      return _mapFrom(jsonDecode(match.group(0)!));
    }
  }

  List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return [
      for (final item in value)
        if (item != null && item.toString().trim().isNotEmpty)
          item.toString().trim(),
    ];
  }

  String _cacheKey(String functionName, Map<String, Object?> payload) {
    final json = jsonEncode({'function': functionName, 'payload': payload});
    return 'ai_${_fnv1a(json)}';
  }

  int _fnv1a(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  void _log(Object error, StackTrace stackTrace) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('AiService error: $error');
    debugPrintStack(stackTrace: stackTrace, label: 'AiService stack');
  }
}

class AiToneVariant {
  const AiToneVariant({required this.tone, required this.text});

  final String tone;
  final String text;
}

class AiServiceException implements Exception {
  const AiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
