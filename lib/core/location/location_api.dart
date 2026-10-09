import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';
import 'captured_location.dart';

/// Talks to the backend user-location endpoints (`/my/location`). Requires an
/// authenticated Dio (Bearer interceptor) — added with the auth phase.
class LocationApi {
  LocationApi(this._dio);

  final Dio _dio;

  /// Upserts the user's current location. `PUT /my/location`.
  Future<void> updateMyLocation(CapturedLocation location) async {
    await _dio.put<Map<String, dynamic>>('/my/location', data: location.toJson());
  }
}

final locationApiProvider = Provider<LocationApi>((ref) {
  return LocationApi(ref.watch(dioProvider));
});
