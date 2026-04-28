import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../data/repositories/firebase_profile_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return FirebaseProfileRepository(ref.watch(firebaseFirestoreProvider));
});

final userProfileProvider = StreamProvider.family<UserProfile?, String>((
  ref,
  userId,
) {
  return ref.watch(profileRepositoryProvider).watchUserProfile(userId);
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream<UserProfile?>.value(null);
  }
  return ref.watch(profileRepositoryProvider).watchUserProfile(user.id);
});
