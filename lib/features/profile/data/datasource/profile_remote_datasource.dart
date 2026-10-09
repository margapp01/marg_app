import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/cms_content.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/user_device.dart';

/// Talks to `/my/profile*`, `/my/devices`, `/my/account`, and `/cms/*`.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dio);
  final Dio _dio;

  Map<String, dynamic> _data(Response<dynamic> res) => ((res.data as Map)['data'] as Map).cast<String, dynamic>();
  List<dynamic> _list(Response<dynamic> res) => ((res.data as Map)['data'] as List?) ?? const [];

  Future<Profile> getProfile() async {
    final res = await _dio.get<dynamic>('/my/profile');
    return Profile.fromJson(_data(res));
  }

  /// Partial update — only non-null fields are sent.
  Future<Profile> updateProfile({
    String? name,
    DateTime? dob,
    String? gender,
    String? city,
    String? preferredLanguage,
    List<String>? interests,
    List<String>? favoriteDeities,
    String? visitFrequency,
    List<String>? preferredRouteTypes,
    List<String>? festivalInterests,
    int? nearbyRadiusKm,
    String? profilePhoto,
  }) async {
    final body = <String, dynamic>{
      'name': ?name,
      'dob': ?dob?.toUtc().toIso8601String(),
      'gender': ?gender,
      'city': ?city,
      'preferredLanguage': ?preferredLanguage,
      'interests': ?interests,
      'favoriteDeities': ?favoriteDeities,
      'visitFrequency': ?visitFrequency,
      'preferredRouteTypes': ?preferredRouteTypes,
      'festivalInterests': ?festivalInterests,
      'nearbyRadiusKm': ?nearbyRadiusKm,
      'profilePhoto': ?profilePhoto,
    };
    final res = await _dio.patch<dynamic>('/my/profile', data: body);
    return Profile.fromJson(_data(res));
  }

  /// Presigns a profile-photo upload, PUTs the bytes, then records it as the
  /// avatar — returning the refreshed profile.
  Future<Profile> uploadAvatar({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) async {
    final presign = _data(await _dio.post<dynamic>('/my/profile/photo/upload-url', data: {
      'fileName': fileName,
      'mimeType': mimeType,
    }));
    final uploadUrl = presign['uploadUrl'] as String;
    final objectKey = presign['objectKey'] as String;

    // Direct PUT to storage (bypasses the API's base URL + auth interceptor).
    await Dio().put<dynamic>(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(headers: {'Content-Type': mimeType, Headers.contentLengthHeader: bytes.length}),
    );

    final res = await _dio.post<dynamic>('/my/profile/photo', data: {
      'objectKey': objectKey,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileSize': bytes.length,
    });
    return Profile.fromJson(_data(res));
  }

  Future<List<UserDevice>> devices() async {
    final res = await _dio.get<dynamic>('/my/devices');
    return _list(res).whereType<Map<dynamic, dynamic>>().map((e) => UserDevice.fromJson(e.cast<String, dynamic>())).toList(growable: false);
  }

  Future<void> removeDevice(String id) => _dio.delete<dynamic>('/my/devices/$id');

  Future<void> deleteAccount() => _dio.delete<dynamic>('/my/account');

  Future<List<Faq>> faqs() async {
    final res = await _dio.get<dynamic>('/cms/faqs', queryParameters: const {'page': 1, 'limit': 50});
    return _list(res).whereType<Map<dynamic, dynamic>>().map((e) => Faq.fromJson(e.cast<String, dynamic>())).toList(growable: false);
  }

  Future<StaticPage> page(PageKind kind) async {
    final res = await _dio.get<dynamic>('/cms/pages/${kind.wire}');
    return StaticPage.fromJson(_data(res));
  }
}

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSource(ref.watch(dioProvider)),
);
