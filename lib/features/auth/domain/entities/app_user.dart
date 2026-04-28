import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final String id;
  final String? email;
  final String? displayName;

  factory AppUser.fromFirebase(firebase_auth.User user) {
    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
