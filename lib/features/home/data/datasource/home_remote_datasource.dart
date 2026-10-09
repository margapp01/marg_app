import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';

/// Talks to the single `GET /home/dashboard` aggregate (authenticated Dio).
/// Optional GPS enables the Nearby Temples section server-side. Returns the raw
/// `data` map so the repository can cache it verbatim for offline reads.
class HomeRemoteDataSource {
  HomeRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetchDashboard({double? latitude, double? longitude}) async {
    final res = await _dio.get<dynamic>(
      '/home/dashboard',
      queryParameters: {
        if (latitude != null && longitude != null) ...{
          'latitude': latitude,
          'longitude': longitude,
        },
      },
    );
    return ((res.data as Map)['data'] as Map).cast<String, dynamic>();
  }
}

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>(
  (ref) => HomeRemoteDataSource(ref.watch(dioProvider)),
);
