import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../core/routes/app_router.dart';
import '../core/services/notification_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_mode_controller.dart';

class CircleApp extends ConsumerStatefulWidget {
  const CircleApp({super.key});

  @override
  ConsumerState<CircleApp> createState() => _CircleAppState();
}

class _CircleAppState extends ConsumerState<CircleApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(notificationControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final notificationTarget = ref.watch(notificationNavigationTargetProvider);
    final foregroundTarget = ref.watch(foregroundNotificationTargetProvider);

    if (notificationTarget != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.read(notificationNavigationTargetProvider.notifier).clear();
        _openNotificationTarget(router, notificationTarget);
      });
    }

    if (foregroundTarget != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.read(foregroundNotificationTargetProvider.notifier).clear();
        final messenger = _scaffoldMessengerKey.currentState;
        if (messenger == null) {
          return;
        }
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: const Text(AppStrings.continueConversation),
            action: SnackBarAction(
              label: AppStrings.open,
              onPressed: () {
                _openNotificationTarget(router, foregroundTarget);
              },
            ),
          ),
        );
      });
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
    );
  }

  void _openNotificationTarget(
    GoRouter router,
    NotificationNavigationTarget target,
  ) {
    if (target.type == NotificationTargetType.comment) {
      router.push(AppRoutes.commentsPath(target.postId));
      return;
    }
    ref.read(feedTargetPostIdProvider.notifier).set(target.postId);
    router.go(AppRoutes.home);
  }
}
