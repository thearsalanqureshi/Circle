import '../constants/app_strings.dart';
import '../errors/image_too_large_exception.dart';

class BackendErrorMapper {
  const BackendErrorMapper._();

  static String messageFor(Object error, String fallback) {
    if (error is ImageTooLargeException) {
      return AppStrings.imageTooLarge;
    }
    return fallback;
  }
}
