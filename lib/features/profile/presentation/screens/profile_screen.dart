import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/app_gradient_button.dart';
import '../../../../core/widgets/app_screen_layout.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_repository_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_post_grid.dart';
import '../widgets/profile_tabs.dart';
import '../widgets/profile_theme_selector.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(currentUserProfileProvider);
    final profile =
        profileState.asData?.value ??
        (user == null ? null : UserProfile.fromAppUser(user));

    return AppScreenLayout(
      title: AppStrings.me,
      child: ListView(
        key: const PageStorageKey<String>(AppRoutes.profile),
        padding: const EdgeInsets.only(
          bottom: AppSizes.shellScrollBottomPadding,
        ),
        children: [
          if (profileState.hasError) ...[
            const AppErrorBanner(message: AppStrings.profileLoadFailed),
            const SizedBox(height: AppSpacing.md),
          ],
          if (profile != null)
            ProfileHeader(
              title: profile.displayName,
              subtitle: profile.email ?? AppStrings.profilePostsEmptyBody,
              photoUrl: profile.photoUrl,
              postsCount: profile.postsCount,
              followersCount: profile.followersCount,
              followingCount: profile.followingCount,
            ),
          const SizedBox(height: AppSpacing.lg),
          const ProfileThemeSelector(),
          const SizedBox(height: AppSpacing.lg),
          AppGradientButton(
            label: AppStrings.logout,
            isLoading: authState.isLoading,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const ProfileTabs(),
          const SizedBox(height: AppSpacing.md),
          if (user != null) ProfilePostGrid(userId: user.id),
        ],
      ),
    );
  }
}
