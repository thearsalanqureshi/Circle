import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_channels.dart';
import '../../../../core/constants/app_limits.dart';
import '../../../../core/errors/image_too_large_exception.dart';
import '../../domain/entities/selected_post_image.dart';

final postImagePickerProvider = Provider<PostImagePicker>((ref) {
  return const PostImagePicker();
});

final selectedPostImageControllerProvider =
    NotifierProvider.autoDispose<
      SelectedPostImageController,
      AsyncValue<SelectedPostImage?>
    >(SelectedPostImageController.new);

class SelectedPostImageController
    extends Notifier<AsyncValue<SelectedPostImage?>> {
  @override
  AsyncValue<SelectedPostImage?> build() {
    return const AsyncData(null);
  }

  Future<void> pickImage() async {
    state = const AsyncLoading();
    try {
      final picked = await ref
          .read(postImagePickerProvider)
          .pickCompressedImage();

      if (picked == null) {
        state = const AsyncData(null);
        return;
      }

      final bytes = picked.bytes;
      if (bytes.lengthInBytes > AppLimits.maxPostImageBytes) {
        throw const ImageTooLargeException();
      }

      state = AsyncData(picked);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void clear() {
    state = const AsyncData(null);
  }
}

class PostImagePicker {
  const PostImagePicker({
    MethodChannel channel = const MethodChannel(AppChannels.postImagePicker),
  }) : _channel = channel;

  final MethodChannel _channel;

  Future<SelectedPostImage?> pickCompressedImage() async {
    try {
      final result = await _channel
          .invokeMapMethod<String, Object?>(AppChannels.pickCompressedImage, {
            'maxWidth': AppLimits.pickedImageMaxWidth,
            'maxHeight': AppLimits.pickedImageMaxHeight,
            'quality': AppLimits.pickedImageQuality,
            'maxBytes': AppLimits.maxPostImageBytes,
          });
      if (result == null) {
        return null;
      }

      final bytes = result['bytes'];
      if (bytes is! Uint8List) {
        return null;
      }

      return SelectedPostImage(
        bytes: bytes,
        fileName: result['fileName'] as String? ?? 'post.jpg',
        contentType: result['contentType'] as String? ?? 'image/jpeg',
      );
    } on PlatformException catch (error) {
      if (error.code == 'image-too-large') {
        throw const ImageTooLargeException();
      }
      rethrow;
    }
  }
}
