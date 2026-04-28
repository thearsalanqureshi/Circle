import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_repository_provider.dart';

class ExploreSearchState {
  const ExploreSearchState({
    required this.rawQuery,
    required this.debouncedQuery,
  });

  final String rawQuery;
  final String debouncedQuery;

  ExploreSearchState copyWith({String? rawQuery, String? debouncedQuery}) {
    return ExploreSearchState(
      rawQuery: rawQuery ?? this.rawQuery,
      debouncedQuery: debouncedQuery ?? this.debouncedQuery,
    );
  }
}

final exploreSearchControllerProvider =
    NotifierProvider.autoDispose<ExploreSearchController, ExploreSearchState>(
      ExploreSearchController.new,
    );

final exploreUsersProvider = StreamProvider.autoDispose<List<UserProfile>>((
  ref,
) {
  final query = ref.watch(
    exploreSearchControllerProvider.select((state) => state.debouncedQuery),
  );
  debugPrint('exploreUsersProvider query="$query"');
  return ref
      .watch(profileRepositoryProvider)
      .watchUsers(query: query, limit: AppLimits.exploreUsersPageSize);
});

class ExploreSearchController extends Notifier<ExploreSearchState> {
  Timer? _debounceTimer;

  @override
  ExploreSearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const ExploreSearchState(rawQuery: '', debouncedQuery: '');
  }

  void update(String query) {
    state = state.copyWith(rawQuery: query);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppLimits.exploreSearchDebounce, () {
      final normalized = query.trim();
      if (state.debouncedQuery == normalized) {
        return;
      }
      state = state.copyWith(debouncedQuery: normalized);
    });
  }
}
