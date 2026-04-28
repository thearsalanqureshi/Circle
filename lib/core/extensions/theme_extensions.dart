import 'package:flutter/material.dart';

import '../theme/circle_theme_colors.dart';

extension CircleThemeContext on BuildContext {
  CircleThemeColors get circleColors {
    final colors = Theme.of(this).extension<CircleThemeColors>();
    assert(colors != null, 'CircleThemeColors must be registered.');
    return colors!;
  }
}
