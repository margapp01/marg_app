import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/knowledge_models.dart';

/// Reads the public CMS + spiritual-content endpoints for the Knowledge Hub:
/// `/cms/blogs`, `/cms/announcements`, `/cms/faqs`, `/cms/pages/:kind`,
/// `/cms/banners`, `/quotes/daily`, `/festivals/*`, and `/search`.
///
/// Every endpoint here already existed — the hub adds no backend surface.
class KnowledgeRemoteDataSource {
  KnowledgeRemoteDataSource(this._dio);
  final Dio _dio;

  List<dynamic> _list(Response<dynamic> res) => ((res.data as Map)['data'] as List?) ?? const [];
  Map<String, dynamic>? _obj(Response<dynamic> res) {
    final d = (res.data as Map)['data'];
    return d is Map ? d.cast<String, dynamic>() : null;
  }

  List<T> _map<T>(Response<dynamic> res, T Function(Map<String, dynamic>) f) =>
      _list(res).whereType<Map<dynamic, dynamic>>().map((e) => f(e.cast<String, dynamic>())).toList(growable: false);

  // ── Blogs ──────────────────────────────────────────────────────────────
  Future<List<Blog>> blogs({int limit = 50}) async {
    final res = await _dio.get<dynamic>('/cms/blogs', queryParameters: {'limit': limit});
    return _map(res, Blog.fromJson);
  }

  Future<Blog> blog(String slug) async {
    final res = await _dio.get<dynamic>('/cms/blogs/$slug');
    return Blog.fromJson(_obj(res) ?? const {});
  }

  /// Blog search via the unified `/search` endpoint (hits carry title / slug /
  /// category / cover only — no body, so reading-time isn't shown on results).
  Future<List<Blog>> searchBlogs(String query, {int limit = 20}) async {
    final res = await _dio.get<dynamic>('/search', queryParameters: {'q': query, 'types': 'blogs', 'limit': limit});
    final data = ((res.data as Map)['data'] as Map?) ?? const {};
    final results = (data['results'] as Map?) ?? const {};
    final blogs = (results['blogs'] as List?) ?? const [];
    return blogs
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Blog.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  // ── Announcements / FAQs / Banners ───────────────────────────────────────
  Future<List<Announcement>> announcements({int limit = 50}) async {
    final res = await _dio.get<dynamic>('/cms/announcements', queryParameters: {'limit': limit});
    return _map(res, Announcement.fromJson);
  }

  Future<List<Faq>> faqs({int limit = 100}) async {
    final res = await _dio.get<dynamic>('/cms/faqs', queryParameters: {'limit': limit});
    return _map(res, Faq.fromJson);
  }

  Future<List<KnowledgeBanner>> banners({int limit = 10}) async {
    final res = await _dio.get<dynamic>('/cms/banners', queryParameters: {'limit': limit});
    return _map(res, KnowledgeBanner.fromJson);
  }

  // ── Quotes / Festivals ───────────────────────────────────────────────────
  Future<Quote?> dailyQuote() async {
    final res = await _dio.get<dynamic>('/quotes/daily');
    final obj = _obj(res);
    return obj == null ? null : Quote.fromJson(obj);
  }

  Future<List<Festival>> upcomingFestivals({String? scope, int limit = 20}) async {
    final res = await _dio.get<dynamic>('/festivals/upcoming', queryParameters: {
      'limit': limit,
      'scope': ?scope,
    });
    return _map(res, Festival.fromJson);
  }

  Future<Festival> festival(String slug) async {
    final res = await _dio.get<dynamic>('/festivals/$slug');
    return Festival.fromJson(_obj(res) ?? const {});
  }

  // ── Static pages ─────────────────────────────────────────────────────────
  Future<StaticPage> staticPage(PageKind kind) async {
    final res = await _dio.get<dynamic>('/cms/pages/${kind.wire}');
    return StaticPage.fromJson(_obj(res) ?? const {});
  }
}

final knowledgeRemoteDataSourceProvider = Provider<KnowledgeRemoteDataSource>(
  (ref) => KnowledgeRemoteDataSource(ref.watch(dioProvider)),
);
