import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_limits.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/backend_error_mapper.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_screen_layout.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../providers/explore_users_provider.dart';
import '../widgets/explore_search_bar.dart';
import '../widgets/user_card.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(
      exploreSearchControllerProvider.select((state) => state.debouncedQuery),
    );
    final users = ref.watch(exploreUsersProvider);

    return AppScreenLayout(
      title: AppStrings.explore,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExploreSearchBar(
            onChanged: ref
                .read(exploreSearchControllerProvider.notifier)
                .update,
          ),
          Expanded(
            child: query.isEmpty
                ? const _ExploreDiscoveryContent()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      const _SectionTitle(AppStrings.people),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: users.when(
                          data: (items) => _ExploreUsersList(users: items),
                          loading: () => const _ExploreLoadingList(),
                          error: (error, stackTrace) => AppEmptyState(
                            icon: Icons.search_off_outlined,
                            title: AppStrings.exploreEmptyTitle,
                            body: BackendErrorMapper.messageFor(
                              error,
                              AppStrings.exploreLoadFailed,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ExploreDiscoveryContent extends ConsumerWidget {
  const _ExploreDiscoveryContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentUsers = ref.watch(recentUsersProvider);
    final activeUsers = ref.watch(activeUsersProvider);

    return CustomScrollView(
      key: const PageStorageKey<String>('explore_discovery'),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        _ExploreUserSection(title: AppStrings.recent, state: recentUsers),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        _ExploreUserSection(title: AppStrings.active, state: activeUsers),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.shellScrollBottomPadding),
        ),
      ],
    );
  }
}

class _ExploreUserSection extends StatelessWidget {
  const _ExploreUserSection({required this.title, required this.state});

  final String title;
  final AsyncValue<List<UserProfile>> state;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (users) {
        if (users.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _SectionTitle(title),
              ),
            ),
            _ExploreUsersSliver(users: users),
          ],
        );
      },
      loading: () => SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _SectionTitle(title),
            ),
          ),
          const _ExploreLoadingSliver(),
        ],
      ),
      error: (error, stackTrace) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Text(
            BackendErrorMapper.messageFor(error, AppStrings.exploreLoadFailed),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}

class _ExploreUsersSliver extends StatelessWidget {
  const _ExploreUsersSliver({required this.users});

  final List<UserProfile> users;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final isWide = width >= AppBreakpoints.mobile;
        if (!isWide) {
          return SliverList.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: AppSpacing.md);
            },
            itemBuilder: (context, index) {
              return UserCard(
                key: ValueKey(users[index].id),
                user: users[index],
              );
            },
          );
        }

        return SliverGrid.builder(
          itemCount: users.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: AppSizes.gridAspectWide,
          ),
          itemBuilder: (context, index) {
            return UserCard(key: ValueKey(users[index].id), user: users[index]);
          },
        );
      },
    );
  }
}

class _ExploreLoadingSliver extends StatelessWidget {
  const _ExploreLoadingSliver();

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: AppLimits.exploreSkeletonUserCount,
      separatorBuilder: (context, index) {
        return const SizedBox(height: AppSpacing.md);
      },
      itemBuilder: (context, index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
          ),
          child: const SizedBox(height: AppSizes.inputMinHeight * 2),
        );
      },
    );
  }
}

class _ExploreUsersList extends StatelessWidget {
  const _ExploreUsersList({required this.users});

  final List<UserProfile> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const AppEmptyState(
        icon: Icons.search_off_outlined,
        title: AppStrings.exploreEmptyTitle,
        body: AppStrings.exploreEmptyBody,
      );
    }

    return CustomScrollView(
      key: const PageStorageKey<String>(AppRoutes.explore),
      slivers: [
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent;
            final isWide = width >= AppBreakpoints.mobile;
            if (!isWide) {
              return SliverList.separated(
                itemCount: users.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: AppSpacing.md);
                },
                itemBuilder: (context, index) {
                  return UserCard(
                    key: ValueKey(users[index].id),
                    user: users[index],
                  );
                },
              );
            }

            return SliverGrid.builder(
              itemCount: users.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: AppSizes.gridAspectWide,
              ),
              itemBuilder: (context, index) {
                return UserCard(
                  key: ValueKey(users[index].id),
                  user: users[index],
                );
              },
            );
          },
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.shellScrollBottomPadding),
        ),
      ],
    );
  }
}

class _ExploreLoadingList extends StatelessWidget {
  const _ExploreLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSizes.shellScrollBottomPadding),
      itemCount: AppLimits.exploreSkeletonUserCount,
      separatorBuilder: (context, index) {
        return const SizedBox(height: AppSpacing.md);
      },
      itemBuilder: (context, index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
          ),
          child: const SizedBox(height: AppSizes.inputMinHeight * 2),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
