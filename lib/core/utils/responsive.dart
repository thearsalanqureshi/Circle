import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../constants/app_dimensions.dart';

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  bool get isTabletWidth => screenSize.width >= AppBreakpoints.mobile;

  double get pagePadding {
    final width = screenSize.width;
    if (width >= AppBreakpoints.tablet) {
      return AppSpacing.xxl;
    }
    if (width >= AppBreakpoints.mobile) {
      return AppSpacing.xl;
    }
    return AppSpacing.lg;
  }

  double constrainedContentWidth(double maxWidth) {
    return math.min(screenSize.width - pagePadding * 2, maxWidth);
  }
}
