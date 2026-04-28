import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_strings.dart';

class AuthErrorMapper {
  const AuthErrorMapper._();

  static String messageFor(Object? error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-credential' ||
        'wrong-password' => AppStrings.authInvalidCredentials,
        'email-already-in-use' => AppStrings.authEmailInUse,
        'weak-password' => AppStrings.authWeakPassword,
        'user-not-found' => AppStrings.authUserNotFound,
        'network-request-failed' => AppStrings.authNetwork,
        _ => error.message ?? AppStrings.authUnknown,
      };
    }

    return AppStrings.authUnknown;
  }
}
