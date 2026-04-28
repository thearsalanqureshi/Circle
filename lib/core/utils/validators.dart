import '../constants/app_strings.dart';

class Validators {
  const Validators._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    return null;
  }

  static String? email(String? value) {
    final requiredMessage = required(value);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (!_emailPattern.hasMatch(value!.trim())) {
      return AppStrings.validationEmail;
    }
    return null;
  }

  static String? password(String? value) {
    final requiredMessage = required(value);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (value!.length < 6) {
      return AppStrings.validationPassword;
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final passwordMessage = Validators.password(value);
    if (passwordMessage != null) {
      return passwordMessage;
    }
    if (value != password) {
      return AppStrings.validationPasswordMatch;
    }
    return null;
  }
}
