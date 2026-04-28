import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_screen_layout.dart';
import '../../../../core/widgets/gradient_glow_background.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_repository_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_post_grid.dart';

class OtherProfileScreen extends ConsumerWidget {
  const OtherProfileScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider(userId));

    return GradientGlowBackground(
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: AppScreenLayout(
          title: AppStrings.otherProfile,
          action: IconButton(
            tooltip: AppStrings.close,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close),
          ),
          child: profileState.when(
            data: (profile) {
              if (profile == null) {
                return const AppEmptyState(
                  icon: Icons.person_search_outlined,
                  title: AppStrings.profileUnavailableTitle,
                  body: AppStrings.profileUnavailableBody,
                );
              }
              return _OtherProfileContent(profile: profile);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => const AppEmptyState(
              icon: Icons.error_outline,
              title: AppStrings.profileUnavailableTitle,
              body: AppStrings.profileLoadFailed,
            ),
          ),
        ),
      ),
    );
  }
}

class _OtherProfileContent extends StatelessWidget {
  const _OtherProfileContent({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        ProfileHeader(
          title: profile.displayName,
          subtitle: profile.email ?? AppStrings.profilePostsEmptyBody,
          photoUrl: profile.photoUrl,
          postsCount: profile.postsCount,
          followersCount: profile.followersCount,
          followingCount: profile.followingCount,
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfilePostGrid(userId: profile.id, respectProfileTabs: false),
      ],
    );
  }
}
