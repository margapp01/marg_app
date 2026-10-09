import 'dart:typed_data';

/// An image the user picked from the gallery or camera, held in memory until
/// it's uploaded. Maps onto the backend upload contract (fileName + mimeType +
/// byte length).
class PickedPhoto {
  const PickedPhoto({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;

  /// One of `image/jpeg`, `image/png`, `image/webp` (the backend allow-list).
  final String mimeType;

  int get sizeBytes => bytes.length;
}
