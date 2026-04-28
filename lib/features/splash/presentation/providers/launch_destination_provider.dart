import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_controller.dart';

enum LaunchDestination { onboarding, login, home }

final launchDestinationProvider = FutureProvider<LaunchDestination>((
  ref,
) async {
  await Future<void>.delayed(AppDurations.splash);

  final onboardingCompleted = ref.watch(onboardingControllerProvider);
  if (!onboardingCompleted) {
    return LaunchDestination.onboarding;
  }

  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) {
    return LaunchDestination.login;
  }

  return LaunchDestination.home;
});
