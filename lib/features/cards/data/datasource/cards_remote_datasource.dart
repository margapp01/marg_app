import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/card_page.dart';
import '../../domain/entities/collection_group.dart';
import '../../domain/entities/collection_stats.dart';
import '../../domain/entities/sacred_card.dart';

/// Talks to `/cards`, `/my/cards`, `/my/cards/stats`, `/my/passport/*`.
class CardsRemoteDataSource {
  CardsRemoteDataSource(this._dio);

  final Dio _dio;

  Map<String, dynamic> _data(Response<dynamic> res) =>
      ((res.data as Map)['data'] as Map).cast<String, dynamic>();

  List<dynamic> _dataList(Response<dynamic> res) =>
      ((res.data as Map)['data'] as List?) ?? const [];

  int _totalPages(Response<dynamic> res) {
    final p = (res.data as Map)['pagination'];
    if (p is Map && p['totalPages'] is num) return (p['totalPages'] as num).toInt();
    return 1;
  }

  Future<CardPage> catalog({
    required int page,
    String? query,
    String? rarity,
    String? seriesId,
    String? seasonId,
    required String sortBy,
    required String sortOrder,
  }) async {
    final res = await _dio.get<dynamic>('/cards', queryParameters: {
      'page': page,
      'limit': 30,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      if (query != null && query.isNotEmpty) 'q': query,
      'rarity': ?rarity,
      'seriesId': ?seriesId,
      'seasonId': ?seasonId,
    });
    final items = _dataList(res)
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => SacredCard.fromCatalog(m.cast<String, dynamic>()))
        .where((c) => c.id.isNotEmpty)
        .toList(growable: false);
    return CardPage(items: items, page: page, totalPages: _totalPages(res));
  }

  Future<CardPage> myCards({required int page, required String sortOrder}) async {
    final res = await _dio.get<dynamic>('/my/cards', queryParameters: {
      'page': page,
      'limit': 30,
      'sortOrder': sortOrder,
    });
    final items = _dataList(res)
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => SacredCard.fromUserCard(m.cast<String, dynamic>()))
        .where((c) => c.id.isNotEmpty)
        .toList(growable: false);
    return CardPage(items: items, page: page, totalPages: _totalPages(res));
  }

  Future<CollectionStats> stats() async {
    final res = await _dio.get<dynamic>('/my/cards/stats');
    return CollectionStats.fromJson(_data(res));
  }

  Future<Set<String>> ownedCardIds() async => (await ownedCards()).keys.toSet();

  /// The user's ownership of each collected card, keyed by catalog card id
  /// (`GET /my/passport/cards` rows carry `cardId` + `userCardId`).
  Future<Map<String, CardOwnership>> ownedCards() async {
    final res = await _dio.get<dynamic>('/my/passport/cards');
    final grouped = (_data(res)['grouped'] as Map?)?.cast<String, dynamic>() ?? const {};
    final owned = <String, CardOwnership>{};
    for (final entry in grouped.values) {
      if (entry is! List) continue;
      for (final row in entry.whereType<Map<dynamic, dynamic>>()) {
        final id = row['cardId'] as String?;
        if (id == null) continue;
        owned[id] = CardOwnership.fromJson({...row.cast<String, dynamic>(), 'id': row['userCardId']});
      }
    }
    return owned;
  }

  Future<SacredCard> catalogDetail(String id) async {
    final res = await _dio.get<dynamic>('/cards/$id');
    return SacredCard.fromCatalog(_data(res));
  }

  /// Owned detail (auth). Throws if the user doesn't own the card.
  Future<SacredCard> myCardDetail(String id) async {
    final res = await _dio.get<dynamic>('/my/cards/$id');
    return SacredCard.fromUserCard(_data(res));
  }

  Future<String?> shareText(String userCardId) async {
    final res = await _dio.get<dynamic>('/my/cards/$userCardId/share');
    return _data(res)['shareText'] as String?;
  }

  Future<List<CollectionGroup>> seriesProgress() => _groups('/my/passport/series');
  Future<List<CollectionGroup>> seasonProgress() => _groups('/my/passport/seasons');

  Future<List<CollectionGroup>> _groups(String path) async {
    final res = await _dio.get<dynamic>(path);
    return _dataList(res)
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => CollectionGroup.fromJson(m.cast<String, dynamic>()))
        .toList(growable: false);
  }
}

final cardsRemoteDataSourceProvider = Provider<CardsRemoteDataSource>(
  (ref) => CardsRemoteDataSource(ref.watch(dioProvider)),
);
