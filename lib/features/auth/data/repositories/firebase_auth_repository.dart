import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/constants/firebase_paths.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return AppUser.fromFirebase(user);
    });
  }

  @override
  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    return AppUser.fromFirebase(user);
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await _upsertUserProfile(user);
    return AppUser.fromFirebase(user);
  }

  @override
  Future<AppUser> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name.trim());
    await user.reload();

    final updatedUser = _firebaseAuth.currentUser ?? user;
    await _upsertUserProfile(updatedUser, fallbackName: name.trim());

    return AppUser.fromFirebase(updatedUser);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  Future<void> _upsertUserProfile(
    firebase_auth.User user, {
    String? fallbackName,
  }) async {
    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : fallbackName?.trim().isNotEmpty == true
        ? fallbackName!.trim()
        : user.email?.split('@').first ?? user.uid;

    final reference = _firestore.doc(FirebasePaths.user(user.uid));
    final snapshot = await reference.get();
    if (snapshot.exists) {
      await reference.set({
        'id': user.uid,
        'displayName': displayName,
        'displayNameLowercase': displayName.trim().toLowerCase(),
        'email': user.email,
        'photoUrl': user.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await reference.set(
      UserProfileModel.createMap(
        id: user.uid,
        displayName: displayName,
        email: user.email,
        photoUrl: user.photoURL,
      ),
    );
  }
}
