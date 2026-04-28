class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const explore = '/explore';
  static const aiStudio = '/ai-studio';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const otherProfile = '/profile/:userId';
  static const comments = '/comments/:postId';

  static const splashName = 'splash';
  static const onboardingName = 'onboarding';
  static const loginName = 'login';
  static const signupName = 'signup';
  static const forgotPasswordName = 'forgot-password';
  static const homeName = 'home';
  static const exploreName = 'explore';
  static const aiStudioName = 'ai-studio';
  static const notificationsName = 'notifications';
  static const profileName = 'profile';
  static const otherProfileName = 'other-profile';
  static const commentsName = 'comments';

  static String otherProfilePath(String userId) => '/profile/$userId';

  static String commentsPath(String postId) => '/comments/$postId';
}
