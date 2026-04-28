import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/hive_keys.dart';
import '../../../../core/services/hive_bootstrap.dart';

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);

final onboardingPageIndexProvider =
    NotifierProvider.autoDispose<OnboardingPageIndex, int>(
      OnboardingPageIndex.new,
    );

class OnboardingController extends Notifier<bool> {
  @override
  bool build() {
    return HiveBootstrap.preferencesBox.get(
          HiveKeys.onboardingCompleted,
          defaultValue: false,
        )
        as bool;
  }

  Future<void> complete() async {
    state = true;
    await HiveBootstrap.preferencesBox.put(HiveKeys.onboardingCompleted, true);
  }
}

class OnboardingPageIndex extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}
