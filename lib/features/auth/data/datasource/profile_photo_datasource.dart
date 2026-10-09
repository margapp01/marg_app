import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/media/picked_photo.dart';
import '../../../../core/network/dio_client.dart';

/// Uploads a profile photo via the three-step R2 flow:
/// 1. `POST /my/profile/photo/upload-url` → presigned PUT + objectKey
/// 2. `PUT <uploadUrl>` → the bytes go straight to storage (no API proxy)
/// 3. `POST /my/profile/photo` → records it and sets it as the avatar
///
/// Steps 1 & 3 use the authenticated Dio; step 2 uses a bare Dio so no Bearer
/// header leaks to the storage host (which would break the presigned request).
class ProfilePhotoDataSource {
  ProfilePhotoDataSource({required Dio authedDio, required Dio uploadDio})
      : _dio = authedDio,
        _upload = uploadDio;

  final Dio _dio;
  final Dio _upload;

  Map<String, dynamic> _data(Response<dynamic> res) =>
      (res.data as Map)['data'] as Map<String, dynamic>;

  /// Runs the full flow and returns the stored public photo URL.
  Future<String> upload(PickedPhoto photo) async {
    final init = await _dio.post<dynamic>(
      '/my/profile/photo/upload-url',
      data: {'fileName': photo.fileName, 'mimeType': photo.mimeType},
    );
    final signed = _data(init);
    final uploadUrl = signed['uploadUrl'] as String;
    final objectKey = signed['objectKey'] as String;

    await _upload.putUri<void>(
      Uri.parse(uploadUrl),
      data: Stream.fromIterable([photo.bytes]),
      options: Options(
        contentType: photo.mimeType,
        headers: {Headers.contentLengthHeader: photo.sizeBytes},
      ),
    );

    final done = await _dio.post<dynamic>(
      '/my/profile/photo',
      data: {
        'objectKey': objectKey,
        'fileName': photo.fileName,
        'mimeType': photo.mimeType,
        'fileSize': photo.sizeBytes,
      },
    );
    return _data(done)['profilePhoto'] as String;
  }
}

final profilePhotoDataSourceProvider = Provider<ProfilePhotoDataSource>(
  (ref) => ProfilePhotoDataSource(
    authedDio: ref.watch(dioProvider),
    uploadDio: Dio(),
  ),
);
