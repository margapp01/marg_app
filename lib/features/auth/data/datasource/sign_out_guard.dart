import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/network/dio_client.dart';

/// Refuses sign-out inside a temple's check-in area, so nobody can switch to
/// another account at the temple and check that one in too. The backend
/// (`GET /my/geofence`) decides what counts as inside; the backend also
/// rejects a second account checking in from the same phone, which is the
/// real guarantee — this guard just stops the attempt early.
class SignOutGuard {
  SignOutGuard(this._dio, this._location);

  final Dio _dio;
  final LocationService _location;

  /// The temple whose check-in area the phone is in, or null. Never asks for
  /// location permission and never blocks on errors: sign-out stays possible
  /// when location is off, denied or unavailable.
  Future<String?> templeHere() async {
    try {
      return await _check().timeout(AppConstants.signOutGuardTimeout);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _check() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) return null;

    final fix = await _location.capture();
    final loc = fix.location;
    if (!fix.isSuccess || loc == null) return null;

    final res = await _dio.get<dynamic>(
      '/my/geofence',
      queryParameters: {'latitude': loc.latitude, 'longitude': loc.longitude},
    );
    final data = ((res.data as Map)['data'] as Map).cast<String, dynamic>();
    if (data['inside'] != true) return null;
    final temple = (data['temple'] as Map?)?.cast<String, dynamic>();
    return (temple?['name'] as String?) ?? '';
  }
}

final signOutGuardProvider = Provider<SignOutGuard>(
  (ref) => SignOutGuard(ref.watch(dioProvider), ref.watch(locationServiceProvider)),
);
