import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/ai_service_provider.dart';

final feedSummaryControllerProvider =
    AsyncNotifierProvider.autoDispose<FeedSummaryController, List<String>>(
      FeedSummaryController.new,
    );

class FeedSummaryController extends AsyncNotifier<List<String>> {
  @override
  FutureOr<List<String>> build() => const [];

  Future<void> summarize(List<String> posts) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(aiServiceProvider).summarizeFeed(posts),
    );
  }

  void clear() {
    state = const AsyncData([]);
  }
}
