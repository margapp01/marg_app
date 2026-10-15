import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/features/temple_visit/data/datasource/temple_visit_remote_datasource.dart';
import 'package:marg_app/features/temple_visit/data/offline_checkins.dart';
import 'package:marg_app/features/temple_visit/domain/entities/checkin_failure.dart';
import 'package:marg_app/features/temple_visit/domain/entities/checkin_request.dart';
import 'package:marg_app/features/temple_visit/domain/entities/checkin_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers each check-in from [verdicts] (by temple id) and records the calls.
class _FakeRemote extends TempleVisitRemoteDataSource {
  _FakeRemote(this.verdicts) : super(Dio());

  final Map<String, Object> verdicts;
  final calls = <(String, CheckinRequest)>[];

  @override
  Future<CheckinResult> checkIn(String templeId, CheckinRequest request) async {
    calls.add((templeId, request));
    final v = verdicts[templeId];
    if (v is CheckinFailure) throw v;
    return CheckinResult.fromJson({'verified': v == true});
  }
}

PendingCheckin _pending(String templeId, DateTime capturedAt, {String userId = 'u1'}) => PendingCheckin(
      userId: userId,
      templeId: templeId,
      slug: '$templeId-slug',
      templeName: 'Temple $templeId',
      request: const CheckinRequest(latitude: 30.73, longitude: 79.06, deviceId: 'd1').forOffline(capturedAt),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  DateTime hoursAgo(int h) => DateTime.now().subtract(Duration(hours: h));

  test('a saved check-in sends the capture time and survives a reload', () async {
    final store = OfflineCheckinStore();
    final at = hoursAgo(5);
    await store.save(_pending('t1', at));

    final saved = (await OfflineCheckinStore().all()).single;
    final json = saved.request.toJson();
    expect(json['offline'], true);
    expect(DateTime.parse(json['capturedAt'] as String), at.toUtc());
    expect(json['deviceId'], 'd1');
    expect(saved.slug, 't1-slug');
  });

  test('one saved check-in per temple per day — a second tap replaces it', () async {
    final store = OfflineCheckinStore();
    final at = DateTime.utc(2026, 10, 14, 6);
    await store.save(_pending('t1', at));
    await store.save(_pending('t1', at.add(const Duration(hours: 1))));
    await store.save(_pending('t2', at));
    expect(await store.all(), hasLength(2));
  });

  test('sync submits oldest first, removes answered ones and reports each', () async {
    final store = OfflineCheckinStore();
    await store.save(_pending('late', hoursAgo(2)));
    await store.save(_pending('early', hoursAgo(10)));
    await store.save(_pending('refused', hoursAgo(6)));
    await store.save(_pending('other-user', hoursAgo(3), userId: 'u2'));
    final remote = _FakeRemote({
      'early': true,
      'late': true,
      'refused': CheckinFailure.fromResponse(statusCode: 400, message: 'You are 2 km away from the temple.'),
    });

    final outcomes = await OfflineCheckinSync(store, remote).run('u1');

    expect(remote.calls.map((c) => c.$1), ['early', 'refused', 'late']);
    expect(remote.calls.every((c) => c.$2.offline), isTrue);
    expect(outcomes.map((o) => o.result),
        [OfflineSyncResult.verified, OfflineSyncResult.rejected, OfflineSyncResult.verified]);
    expect(outcomes[1].message, 'You are 2 km away from the temple.');
    // Only the other account's check-in is left.
    expect((await store.all()).single.userId, 'u2');
  });

  test('still no network, a rate limit or a server error keeps it for later', () async {
    for (final failure in [
      const CheckinFailure.offline('No connection'),
      CheckinFailure.fromResponse(statusCode: 429, message: 'Too many requests'),
      CheckinFailure.fromResponse(statusCode: 503, message: 'Unavailable'),
    ]) {
      SharedPreferences.setMockInitialValues({});
      final store = OfflineCheckinStore();
      await store.save(_pending('t1', hoursAgo(1)));
      final outcomes = await OfflineCheckinSync(store, _FakeRemote({'t1': failure})).run('u1');
      expect(outcomes, isEmpty, reason: failure.message);
      expect(await store.all(), hasLength(1), reason: failure.message);
    }
  });

  test('a check-in older than 3 days is dropped without being sent', () async {
    final store = OfflineCheckinStore();
    await store.save(_pending('t1', hoursAgo(73)));
    final remote = _FakeRemote({'t1': true});

    final outcomes = await OfflineCheckinSync(store, remote).run('u1');

    expect(remote.calls, isEmpty);
    expect(outcomes.single.result, OfflineSyncResult.expired);
    expect(await store.all(), isEmpty);
  });
}
