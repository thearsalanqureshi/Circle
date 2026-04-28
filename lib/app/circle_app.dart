import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
    );
  }
}
