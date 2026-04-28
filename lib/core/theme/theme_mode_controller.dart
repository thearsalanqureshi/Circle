import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/hive_keys.dart';
import '../services/hive_bootstrap.dart';

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final value =
        HiveBootstrap.preferencesBox.get(
              HiveKeys.themeMode,
              defaultValue: ThemeMode.system.name,
            )
            as String;

    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await HiveBootstrap.preferencesBox.put(HiveKeys.themeMode, mode.name);
  }
}
