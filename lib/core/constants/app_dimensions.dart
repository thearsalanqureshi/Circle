class AppBreakpoints {
  const AppBreakpoints._();

  static const mobile = 600.0;
  static const tablet = 840.0;
}

class AppDurations {
  const AppDurations._();

  static const fast = Duration(milliseconds: 180);
  static const formToggle = Duration(milliseconds: 160);
  static const pageTransition = Duration(milliseconds: 240);
  static const splash = Duration(milliseconds: 800);
  static const feedback = Duration(seconds: 3);
}

class AppRadius {
  const AppRadius._();

  static const xs = 4.0;
  static const s = 8.0;
  static const sm = 10.0;
  static const card = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const pill = 32.0;
}

class AppSpacing {
  const AppSpacing._();

  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppSizes {
  const AppSizes._();

  static const authMaxWidth = 480.0;
  static const contentMaxWidth = 720.0;
  static const wideContentMaxWidth = 1180.0;
  static const glowCircleMin = 220.0;
  static const glowCircleMax = 360.0;
  static const buttonMinHeight = 52.0;
  static const buttonLoader = 22.0;
  static const buttonLoaderStroke = 2.0;
  static const checkIcon = 16.0;
  static const inputMinHeight = 56.0;
  static const iconButton = 44.0;
  static const emptyStateIcon = 32.0;
  static const avatarSm = 36.0;
  static const avatarMd = 44.0;
  static const avatarLg = 72.0;
  static const profileAvatarRadius = 28.0;
  static const postImageMinHeight = 160.0;
  static const postImageMaxHeight = 260.0;
  static const postActionBarHeight = 44.0;
  static const postActionCountWidth = 40.0;
  static const paginationLoadOffset = 360.0;
  static const userCardMinWidth = 168.0;
  static const aiToolCardMinWidth = 220.0;
  static const profileGridTileMinWidth = 104.0;
  static const gridAspectWide = 1.18;
  static const gridAspectList = 2.45;
  static const aiToolAspectWide = 1.08;
  static const aiToolAspectList = 2.15;
  static const profileGridAspect = 1.0;
  static const onboardingVisualMinHeight = 220.0;
  static const onboardingIcon = 72.0;
  static const onboardingDot = 8.0;
  static const onboardingDotActiveWidth = 22.0;
  static const bottomNavHeight = 72.0;
  static const bottomNavVerticalPadding = AppSpacing.xs + AppSpacing.md;
  static const shellScrollBottomPadding =
      bottomNavHeight + bottomNavVerticalPadding + AppSpacing.xxl;
}
