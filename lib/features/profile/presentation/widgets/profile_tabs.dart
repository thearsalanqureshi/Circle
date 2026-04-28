import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../providers/profile_tab_controller.dart';

class ProfileTabs extends ConsumerWidget {
  const ProfileTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(profileTabControllerProvider);

    return SegmentedButton<ProfileTab>(
      segments: const [
        ButtonSegment(
          value: ProfileTab.posts,
          label: Text(AppStrings.posts),
          icon: Icon(Icons.grid_on_outlined),
        ),
        ButtonSegment(
          value: ProfileTab.saved,
          label: Text(AppStrings.saved),
          icon: Icon(Icons.bookmark_border_outlined),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        ref.read(profileTabControllerProvider.notifier).select(selection.first);
      },
    );
  }
}
