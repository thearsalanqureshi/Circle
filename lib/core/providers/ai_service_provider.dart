import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ai_service.dart';
import '../services/gemini_service.dart';
import '../services/hive_bootstrap.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  // TEMPORARY TEST IMPLEMENTATION:
  // Direct Gemini is used only while Cloud Functions are unavailable. To revert,
  // replace GeminiService with the Firebase Callable Functions implementation.
  return AiService(
    geminiService: ref.watch(geminiServiceProvider),
    cacheBox: HiveBootstrap.aiCacheBox,
  );
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});
