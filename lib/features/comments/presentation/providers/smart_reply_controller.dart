import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/ai_service_provider.dart';

final smartReplyControllerProvider =
    AsyncNotifierProvider.autoDispose<SmartReplyController, List<String>>(
      SmartReplyController.new,
    );

class SmartReplyController extends AsyncNotifier<List<String>> {
  String? _lastCommentText;
  List<String> _lastContext = const [];

  @override
  FutureOr<List<String>> build() => const [];

  Future<void> generate({
    required String commentText,
    List<String> context = const [],
  }) async {
    _lastCommentText = commentText;
    _lastContext = context;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(aiServiceProvider)
          .generateSmartReply(commentText: commentText, context: context),
    );
  }

  void clear() {
    state = const AsyncData([]);
  }

  Future<void> retry() async {
    final commentText = _lastCommentText;
    if (commentText == null) {
      return;
    }
    await generate(commentText: commentText, context: _lastContext);
  }
}
