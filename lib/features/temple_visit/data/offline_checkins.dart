import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/constants/app_constants.dart';
import '../domain/entities/checkin_failure.dart';
import '../domain/entities/checkin_request.dart';
import 'datasource/temple_visit_remote_datasource.dart';

/// A check-in captured at the shrine without network, waiting to be submitted.
class PendingCheckin {
  const PendingCheckin({
    required this.userId,
    required this.templeId,
    required this.slug,
    required this.templeName,
    required this.request,
  });

  final String userId;
  final String templeId;
  final String slug;
  final String templeName;

  /// Carries `offline: true` and the capture time.
  final CheckinRequest request;

  DateTime get capturedAt => request.capturedAt ?? DateTime.now();

  /// One per user, temple and (UTC) day — the backend's own check-in rule.
  String get key => '$userId|$templeId|${capturedAt.toUtc().toIso8601String().substring(0, 10)}';

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'templeId': templeId,
        'slug': slug,
        'templeName': templeName,
        'request': request.toJson(),
      };

  static PendingCheckin? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final j = raw.cast<String, dynamic>();
    final request = j['request'];
    if (j['userId'] is! String || j['templeId'] is! String || request is! Map) return null;
    return PendingCheckin(
      userId: j['userId'] as String,
      templeId: j['templeId'] as String,
      slug: (j['slug'] as String?) ?? '',
      templeName: (j['templeName'] as String?) ?? '',
      request: CheckinRequest.fromJson(request.cast<String, dynamic>()),
    );
  }
}

/// Saved offline check-ins, kept in SharedPreferences — deliberately not in the
/// read-through cache, which "Clear cache" wipes.
class OfflineCheckinStore {
  static const _key = 'offline_checkins_v1';

  Future<List<PendingCheckin>> all() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map(PendingCheckin.fromJson).whereType<PendingCheckin>().toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves [checkin], replacing an earlier one for the same temple and day.
  Future<void> save(PendingCheckin checkin) async {
    final list = (await all())..removeWhere((c) => c.key == checkin.key);
    await _write([...list, checkin]);
  }

  Future<void> remove(PendingCheckin checkin) async {
    final list = (await all())..removeWhere((c) => c.key == checkin.key);
    await _write(list);
  }

  Future<void> _write(List<PendingCheckin> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list.map((c) => c.toJson()).toList()));
  }
}

enum OfflineSyncResult { verified, notVerified, rejected, expired }

class OfflineSyncOutcome {
  const OfflineSyncOutcome(this.checkin, this.result, [this.message]);
  final PendingCheckin checkin;
  final OfflineSyncResult result;

  /// The backend's own reason when [result] is [OfflineSyncResult.rejected].
  final String? message;
}

/// Submits saved check-ins once the network is back, oldest first. A
/// check-in the server answered (verified or refused) is removed; one that
/// met no network, a rate limit or a server error stays for the next try.
class OfflineCheckinSync {
  OfflineCheckinSync(this._store, this._remote);

  final OfflineCheckinStore _store;
  final TempleVisitRemoteDataSource _remote;
  bool _running = false;

  Future<List<OfflineSyncOutcome>> run(String userId) async {
    if (_running) return const [];
    _running = true;
    try {
      final pending = (await _store.all()).where((c) => c.userId == userId).toList()
        ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
      final outcomes = <OfflineSyncOutcome>[];
      for (final checkin in pending) {
        if (DateTime.now().difference(checkin.capturedAt) > AppConstants.offlineCheckinMaxAge) {
          await _store.remove(checkin);
          outcomes.add(OfflineSyncOutcome(checkin, OfflineSyncResult.expired));
          continue;
        }
        try {
          final result = await _remote.checkIn(checkin.templeId, checkin.request);
          await _store.remove(checkin);
          outcomes.add(OfflineSyncOutcome(checkin, result.verified ? OfflineSyncResult.verified : OfflineSyncResult.notVerified));
        } on CheckinFailure catch (f) {
          final retryLater = f.kind == CheckinFailureKind.offline ||
              f.kind == CheckinFailureKind.rateLimited ||
              (f.statusCode ?? 0) >= 500;
          if (retryLater) break;
          await _store.remove(checkin);
          outcomes.add(OfflineSyncOutcome(checkin, OfflineSyncResult.rejected, f.message));
        }
      }
      return outcomes;
    } finally {
      _running = false;
    }
  }
}

final offlineCheckinStoreProvider = Provider<OfflineCheckinStore>((ref) => OfflineCheckinStore());

final offlineCheckinSyncProvider = Provider<OfflineCheckinSync>(
  (ref) => OfflineCheckinSync(ref.watch(offlineCheckinStoreProvider), ref.watch(templeVisitRemoteDataSourceProvider)),
);
