import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginPasswordObscuredProvider =
    NotifierProvider.autoDispose<LoginPasswordObscured, bool>(
      LoginPasswordObscured.new,
    );

final signUpPasswordObscuredProvider =
    NotifierProvider.autoDispose<SignUpPasswordObscured, bool>(
      SignUpPasswordObscured.new,
    );

final signUpConfirmPasswordObscuredProvider =
    NotifierProvider.autoDispose<SignUpConfirmPasswordObscured, bool>(
      SignUpConfirmPasswordObscured.new,
    );

final rememberMeProvider = NotifierProvider.autoDispose<RememberMe, bool>(
  RememberMe.new,
);

abstract class ToggleBoolController extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }
}

class LoginPasswordObscured extends ToggleBoolController {}

class SignUpPasswordObscured extends ToggleBoolController {}

class SignUpConfirmPasswordObscured extends ToggleBoolController {}

class RememberMe extends ToggleBoolController {
  void setValue(bool value) {
    state = value;
  }
}
