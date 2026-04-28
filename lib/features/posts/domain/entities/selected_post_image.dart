import 'dart:typed_data';

class SelectedPostImage {
  const SelectedPostImage({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;

  int get sizeInBytes => bytes.lengthInBytes;
}
