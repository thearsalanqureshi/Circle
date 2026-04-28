import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_gradient_button.dart';
import '../../../../core/widgets/gradient_glow_background.dart';
import '../providers/onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.group_outlined,
      title: AppStrings.onboardingTitleOne,
      body: AppStrings.onboardingBodyOne,
    ),
    _OnboardingPageData(
      icon: Icons.auto_awesome_motion_outlined,
      title: AppStrings.onboardingTitleTwo,
      body: AppStrings.onboardingBodyTwo,
    ),
    _OnboardingPageData(
      icon: Icons.bolt_outlined,
      title: AppStrings.onboardingTitleThree,
      body: AppStrings.onboardingBodyThree,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = ref.watch(onboardingPageIndexProvider);
    final isLastPage = pageIndex == _pages.length - 1;

    return Scaffold(
      body: GradientGlowBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth >= AppBreakpoints.mobile
                  ? AppSpacing.xxl
                  : AppSpacing.lg;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (index) {
                          ref
                              .read(onboardingPageIndexProvider.notifier)
                              .setIndex(index);
                        },
                        itemBuilder: (context, index) {
                          return _OnboardingPage(data: _pages[index]);
                        },
                      ),
                    ),
                    _OnboardingDots(
                      count: _pages.length,
                      activeIndex: pageIndex,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSizes.authMaxWidth,
                      ),
                      child: AppGradientButton(
                        label: isLastPage
                            ? AppStrings.getStarted
                            : AppStrings.next,
                        onPressed: () => _handlePrimaryAction(isLastPage),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handlePrimaryAction(bool isLastPage) async {
    if (!isLastPage) {
      await _pageController.nextPage(
        duration: AppDurations.pageTransition,
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await ref.read(onboardingControllerProvider.notifier).complete();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.contentMaxWidth),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.onboardingVisualMinHeight,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  border: Border.all(color: colors.inputBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Icon(
                    data.icon,
                    color: AppColors.darkTextPrimary,
                    size: AppSizes.onboardingIcon,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              data.body,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingDots extends StatelessWidget {
  const _OnboardingDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          width: isActive
              ? AppSizes.onboardingDotActiveWidth
              : AppSizes.onboardingDot,
          height: AppSizes.onboardingDot,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            color: isActive ? AppColors.accentOrange : colors.inputBorder,
          ),
        );
      }),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
