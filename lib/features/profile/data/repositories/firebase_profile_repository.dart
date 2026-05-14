import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firebase_paths.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

class FirebaseProfileRepository implements ProfileRepository {
  const FirebaseProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<UserProfile?> watchUserProfile(String userId) {
    return _firestore.doc(FirebasePaths.user(userId)).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return null;
      }
      return UserProfileModel.fromSnapshot(snapshot);
    });
  }

  @override
  Stream<List<UserProfile>> watchUsers({
    required String query,
    required int limit,
  }) {
    final trimmedQuery = query.trim().toLowerCase();
    Query<Map<String, dynamic>> usersQuery = _firestore.collection(
      FirebasePaths.users,
    );

    if (trimmedQuery.isEmpty) {
      usersQuery = usersQuery.orderBy('displayNameLowercase').limit(limit);
    } else {
      usersQuery = usersQuery
          .orderBy('displayNameLowercase')
          .startAt([trimmedQuery])
          .endAt(['$trimmedQuery\uf8ff'])
          .limit(limit);
    }

    return usersQuery.snapshots().map((snapshot) {
      return snapshot.docs.map(UserProfileModel.fromSnapshot).toList();
    });
  }

  @override
  Stream<List<UserProfile>> watchRecentUsers({required int limit}) {
    return _firestore
        .collection(FirebasePaths.users)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs.map(UserProfileModel.fromSnapshot).toList();
          }
          final fallback = await _firestore
              .collection(FirebasePaths.users)
              .orderBy('displayNameLowercase')
              .limit(limit)
              .get();
          return fallback.docs.map(UserProfileModel.fromSnapshot).toList();
        });
  }

  @override
  Stream<List<UserProfile>> watchActiveUsers({
    required int postLimit,
    required int userLimit,
  }) {
    return _firestore
        .collection(FirebasePaths.posts)
        .orderBy('createdAt', descending: true)
        .limit(postLimit)
        .snapshots()
        .asyncMap((snapshot) async {
          final userIds = <String>[];
          final seen = <String>{};
          for (final post in snapshot.docs) {
            final userId = post.data()['userId'] as String? ?? '';
            if (userId.isNotEmpty && seen.add(userId)) {
              userIds.add(userId);
            }
            if (userIds.length >= userLimit) {
              break;
            }
          }

          final users = <UserProfile>[];
          for (final userId in userIds) {
            final snapshot = await _firestore
                .doc(FirebasePaths.user(userId))
                .get();
            if (snapshot.exists) {
              users.add(UserProfileModel.fromSnapshot(snapshot));
            }
          }
          return users;
        });
  }

  @override
  Future<void> ensureUserProfile(AppUser user) async {
    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email?.split('@').first ?? user.id;
    final reference = _firestore.doc(FirebasePaths.user(user.id));
    final snapshot = await reference.get();
    if (snapshot.exists) {
      await reference.set({
        'displayName': displayName,
        'displayNameLowercase': displayName.trim().toLowerCase(),
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await reference.set(
      UserProfileModel.createMap(
        id: user.id,
        displayName: displayName,
        email: user.email,
        photoUrl: null,
      ),
    );
  }
}
