import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../../core/widgets/app_screen_layout.dart';
import '../../../../core/widgets/gradient_glow_background.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientGlowBackground(
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: AppScreenLayout(
          title: AppStrings.notifications,
          action: IconButton(
            tooltip: AppStrings.close,
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
          ),
          child: ListView.separated(
            itemCount: MockData.notifications.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: AppSpacing.md);
            },
            itemBuilder: (context, index) {
              return NotificationTile(
                notification: MockData.notifications[index],
              );
            },
          ),
        ),
      ),
    );
  }
}
