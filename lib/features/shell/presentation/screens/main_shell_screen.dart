import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/gradient_glow_background.dart';
import '../providers/shell_storage_provider.dart';

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _ShellTab(
      label: AppStrings.feed,
      route: AppRoutes.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _ShellTab(
      label: AppStrings.explore,
      route: AppRoutes.explore,
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
    ),
    _ShellTab(
      label: AppStrings.aiStudio,
      route: AppRoutes.aiStudio,
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
    ),
    _ShellTab(
      label: AppStrings.me,
      route: AppRoutes.profile,
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _selectedIndex(context);
    final pageStorageBucket = ref.watch(shellPageStorageBucketProvider);

    return GradientGlowBackground(
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: PageStorage(bucket: pageStorageBucket, child: child),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  context.go(_tabs[index].route);
                },
                destinations: [
                  for (final tab in _tabs)
                    NavigationDestination(
                      icon: Icon(tab.icon),
                      selectedIcon: Icon(tab.activeIcon),
                      label: tab.label,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((tab) => tab.route == location);
    if (index == -1) {
      return 0;
    }
    return index;
  }
}

class _ShellTab {
  const _ShellTab({
    required this.label,
    required this.route,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final String route;
  final IconData icon;
  final IconData activeIcon;
}
