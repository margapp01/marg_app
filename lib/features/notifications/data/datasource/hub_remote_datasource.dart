import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/hub_content.dart';

/// Talks to the public festival + quote endpoints (`/festivals/*`, `/quotes/*`).
class HubRemoteDataSource {
  HubRemoteDataSource(this._dio);
  final Dio _dio;

  List<dynamic> _list(Response<dynamic> res) => ((res.data as Map)['data'] as List?) ?? const [];
  Map<String, dynamic>? _obj(Response<dynamic> res) {
    final d = (res.data as Map)['data'];
    return d is Map ? d.cast<String, dynamic>() : null;
  }

  Future<List<Festival>> upcomingFestivals() async {
    final res = await _dio.get<dynamic>('/festivals/upcoming');
    return _list(res).whereType<Map<dynamic, dynamic>>().map((e) => Festival.fromJson(e.cast<String, dynamic>())).toList(growable: false);
  }

  Future<Festival> festival(String slug) async {
    final res = await _dio.get<dynamic>('/festivals/$slug');
    return Festival.fromJson(_obj(res) ?? const {});
  }

  Future<Quote?> dailyQuote() async {
    final res = await _dio.get<dynamic>('/quotes/daily');
    final obj = _obj(res);
    return obj == null ? null : Quote.fromJson(obj);
  }

  Future<List<Quote>> quotes({int page = 1, int limit = 20}) async {
    final res = await _dio.get<dynamic>('/quotes', queryParameters: {'page': page, 'limit': limit});
    return _list(res).whereType<Map<dynamic, dynamic>>().map((e) => Quote.fromJson(e.cast<String, dynamic>())).toList(growable: false);
  }
}

final hubRemoteDataSourceProvider = Provider<HubRemoteDataSource>(
  (ref) => HubRemoteDataSource(ref.watch(dioProvider)),
);
