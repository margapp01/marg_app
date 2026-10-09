import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'picked_photo.dart';

/// Wraps `image_picker` to hand back a backend-ready [PickedPhoto] (bytes +
/// filename + a validated MIME type). Downscales on pick so avatars stay small.
class ImagePickerService {
  ImagePickerService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const _mimeByExt = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  /// Pick from [source]; returns null if the user cancels. Throws nothing for
  /// cancellation — callers only handle a real failure.
  Future<PickedPhoto?> pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();
    final mimeType = file.mimeType ?? _mimeByExt[ext] ?? 'image/jpeg';
    return PickedPhoto(bytes: bytes, fileName: file.name, mimeType: mimeType);
  }
}

final imagePickerServiceProvider =
    Provider<ImagePickerService>((ref) => ImagePickerService());
