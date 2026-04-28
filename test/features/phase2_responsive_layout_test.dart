import 'package:circle/core/theme/app_theme.dart';
import 'package:circle/features/ai_studio/presentation/screens/ai_studio_screen.dart';
import 'package:circle/features/explore/presentation/providers/explore_users_provider.dart';
import 'package:circle/features/explore/presentation/screens/explore_screen.dart';
import 'package:circle/features/explore/presentation/widgets/explore_search_bar.dart';
import 'package:circle/features/posts/presentation/providers/post_repository_provider.dart';
import 'package:circle/features/profile/domain/entities/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Explore screen does not overflow on a small phone', (
    tester,
  ) async {
    await _pumpAtSize(tester, _exploreScreenForTest());

    expect(tester.takeException(), isNull);
  });

  testWidgets('Explore header stays fixed while people list scrolls', (
    tester,
  ) async {
    await _pumpAtSize(tester, _exploreScreenForTest());

    final searchBar = find.byType(ExploreSearchBar);
    final initialTop = tester.getTopLeft(searchBar).dy;

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(searchBar).dy, initialTop);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AI Studio screen does not overflow on a small phone', (
    tester,
  ) async {
    await _pumpAtSize(
      tester,
      ProviderScope(
        overrides: [
          visibleFeedPostsProvider.overrideWithValue(const AsyncData([])),
        ],
        child: const AiStudioScreen(),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

Widget _exploreScreenForTest() {
  return ProviderScope(
    overrides: [exploreUsersProvider.overrideWithValue(AsyncData(_testUsers))],
    child: const ExploreScreen(),
  );
}

final _testUsers = List<UserProfile>.generate(
  8,
  (index) => UserProfile(
    id: 'user_$index',
    displayName: 'User $index',
    email: 'user$index@example.com',
    photoUrl: null,
    bio: 'Test bio',
    postsCount: index,
    followersCount: index * 10,
    followingCount: 0,
    createdAt: null,
    updatedAt: null,
  ),
);

Future<void> _pumpAtSize(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}
