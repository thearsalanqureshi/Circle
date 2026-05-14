import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/ai_service_provider.dart';

final improvePostControllerProvider =
    AsyncNotifierProvider.autoDispose<ImprovePostController, String?>(
      ImprovePostController.new,
    );

class ImprovePostController extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() => null;

  Future<void> improve(String draft) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(aiServiceProvider).improvePostDraft(draft),
    );
  }

  void clear() {
    state = const AsyncData(null);
  }
}
