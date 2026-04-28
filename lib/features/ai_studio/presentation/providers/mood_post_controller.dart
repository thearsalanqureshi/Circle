import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/ai_service_provider.dart';

final moodPostControllerProvider =
    AsyncNotifierProvider.autoDispose<MoodPostController, String?>(
      MoodPostController.new,
    );

class MoodPostController extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() => null;

  Future<void> generate(String mood) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(aiServiceProvider).generateMoodPost(mood),
    );
  }

  void clear() {
    state = const AsyncData(null);
  }
}
