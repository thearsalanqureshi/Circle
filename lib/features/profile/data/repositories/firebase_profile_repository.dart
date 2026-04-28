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
