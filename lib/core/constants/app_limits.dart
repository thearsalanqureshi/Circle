class AppLimits {
  const AppLimits._();

  static const feedPostsPageSize = 20;
  static const feedPostsCacheSize = 50;
  static const feedSkeletonPostCount = 3;
  static const postTextMaxChars = 800;
  static const commentTextMaxChars = 500;
  static const commentsPageSize = 50;
  static const profilePostsPageSize = 30;
  static const exploreUsersPageSize = 30;
  static const exploreRecentUsersLimit = 8;
  static const exploreActiveUsersLimit = 8;
  static const exploreActivePostsWindow = 24;
  static const exploreSkeletonUserCount = 4;
  static const profileSkeletonTileCount = 6;
  static const firestoreDocumentMaxBytes = 1024 * 1024;
  static const maxPostImageBytes = 300 * 1024;
  static const documentRiskBytes = 850 * 1024;
  static const pickedImageMaxWidth = 960.0;
  static const pickedImageMaxHeight = 960.0;
  static const pickedImageQuality = 60;
  static const aiTimeoutSeconds = 15;
  static const aiMaxAttempts = 2;
  static const aiCacheTtl = Duration(hours: 1);
  static const aiMoodMaxChars = 160;
  static const aiDraftMaxChars = 800;
  static const aiCommentMaxChars = 500;
  static const aiFeedSummaryPostCount = 10;
  static const aiFeedSummaryPostMaxChars = 400;
  static const exploreSearchDebounce = Duration(milliseconds: 300);
}
