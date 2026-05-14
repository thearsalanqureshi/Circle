import 'package:circle/core/constants/app_strings.dart';
import 'package:circle/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('requires non-empty values', () {
      expect(Validators.required(''), AppStrings.validationRequired);
      expect(Validators.required('  '), AppStrings.validationRequired);
      expect(Validators.required('Circle'), isNull);
    });

    test('validates email format', () {
      expect(Validators.email('bad-email'), AppStrings.validationEmail);
      expect(Validators.email('user@circle.app'), isNull);
    });

    test('validates password length and confirmation', () {
      expect(Validators.password('12345'), AppStrings.validationPassword);
      expect(Validators.password('123456'), isNull);
      expect(
        Validators.confirmPassword('abcdef', '123456'),
        AppStrings.validationPasswordMatch,
      );
      expect(Validators.confirmPassword('123456', '123456'), isNull);
    });

    test('validates maximum text length', () {
      expect(
        Validators.maxLength('abcd', 3),
        AppStrings.validationMaxLength(3),
      );
      expect(Validators.maxLength('abc', 3), isNull);
      expect(
        Validators.requiredMaxLength('', 3),
        AppStrings.validationRequired,
      );
    });
  });
}
