import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/ai_service_provider.dart';
import '../../../../core/services/ai_service.dart';

final toneVariantsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      ToneVariantsController,
      List<AiToneVariant>
    >(ToneVariantsController.new);

class ToneVariantsController extends AsyncNotifier<List<AiToneVariant>> {
  @override
  FutureOr<List<AiToneVariant>> build() => const [];

  Future<void> generate(String draft) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(aiServiceProvider).generateToneVariants(draft),
    );
  }

  void clear() {
    state = const AsyncData([]);
  }
}
