import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_studio/presentation/screens/ai_studio_screen.dart';
import '../../features/auth/presentation/providers/auth_repository_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/comments/presentation/screens/comments_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_controller.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/other_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final onboardingCompleted = ref.watch(onboardingControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSplash = location == AppRoutes.splash;
      final isOnboarding = location == AppRoutes.onboarding;
      final isAuthRoute =
          location == AppRoutes.login ||
          location == AppRoutes.signup ||
          location == AppRoutes.forgotPassword;

      if (isSplash) {
        return null;
      }

      if (!onboardingCompleted) {
        return isOnboarding ? null : AppRoutes.onboarding;
      }

      final isLoadingAuth = authState.isLoading;
      final user = authState.asData?.value;
      if (isLoadingAuth) {
        return null;
      }

      if (user == null) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      if (isAuthRoute || isOnboarding) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        pageBuilder: (context, state) => _fadePage(state, const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        pageBuilder: (context, state) =>
            _fadePage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        pageBuilder: (context, state) => _fadePage(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signupName,
        pageBuilder: (context, state) => _fadePage(state, const SignUpScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        pageBuilder: (context, state) =>
            _fadePage(state, const ForgotPasswordScreen()),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.homeName,
            pageBuilder: (context, state) =>
                _fadePage(state, const FeedScreen()),
          ),
          GoRoute(
            path: AppRoutes.explore,
            name: AppRoutes.exploreName,
            pageBuilder: (context, state) =>
                _fadePage(state, const ExploreScreen()),
          ),
          GoRoute(
            path: AppRoutes.aiStudio,
            name: AppRoutes.aiStudioName,
            pageBuilder: (context, state) =>
                _fadePage(state, const AiStudioScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: AppRoutes.profileName,
            pageBuilder: (context, state) =>
                _fadePage(state, const ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.notifications,
        name: AppRoutes.notificationsName,
        pageBuilder: (context, state) =>
            _fadePage(state, const NotificationsScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.otherProfile,
        name: AppRoutes.otherProfileName,
        pageBuilder: (context, state) => _fadePage(
          state,
          OtherProfileScreen(userId: state.pathParameters['userId']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.comments,
        name: AppRoutes.commentsName,
        pageBuilder: (context, state) => _fadePage(
          state,
          CommentsScreen(postId: state.pathParameters['postId']!),
        ),
      ),
    ],
  );
});

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: AppDurations.pageTransition,
    reverseTransitionDuration: AppDurations.fast,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: child,
      );
    },
  );
}
