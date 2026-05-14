import 'dart:io';

import 'package:circle/core/constants/hive_keys.dart';
import 'package:circle/core/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDirectory;

  setUp(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('circle_theme_test_');
    Hive.init(hiveDirectory.path);
    await Hive.openBox<dynamic>(HiveKeys.preferencesBox);
  });

  tearDown(() async {
    await Hive.close();
    if (hiveDirectory.existsSync()) {
      hiveDirectory.deleteSync(recursive: true);
    }
  });

  group('ThemeModeController', () {
    test('defaults to system theme mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeControllerProvider), ThemeMode.system);
    });

    test('persists selected theme mode in Hive', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      expect(container.read(themeModeControllerProvider), ThemeMode.dark);
      expect(
        Hive.box<dynamic>(HiveKeys.preferencesBox).get(HiveKeys.themeMode),
        ThemeMode.dark.name,
      );
    });
  });
}
