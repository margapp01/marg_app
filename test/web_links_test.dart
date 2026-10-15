import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/router/web_links.dart';
import 'package:marg_app/core/services/install_referrer_service.dart';
import 'package:marg_app/core/storage/key_value_store.dart';
import 'package:marg_app/features/referrals/data/datasource/referral_remote_datasource.dart';
import 'package:marg_app/features/referrals/data/referral_attribution.dart';

class _MemoryStore implements KeyValueStore {
  final values = <String, Object>{};
  @override
  Future<String?> getString(String key) async => values[key] as String?;
  @override
  Future<void> setString(String key, String value) async => values[key] = value;
  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;
  @override
  Future<void> setBool(String key, {required bool value}) async => values[key] = value;
  @override
  Future<void> remove(String key) async => values.remove(key);
}

class _Remote extends ReferralRemoteDataSource {
  _Remote({this.fail}) : super(Dio());
  final DioException? fail;
  final applied = <(String, String?)>[];
  @override
  Future<void> apply(String code, {String? source}) async {
    if (fail != null) throw fail!;
    applied.add((code, source));
  }
}

class _Referrer extends InstallReferrerService {
  const _Referrer(this.value);
  final String? value;
  @override
  Future<String?> read() async => value;
}

void main() {
  group('appLocationForWebLink', () {
    String? map(String url) => appLocationForWebLink(Uri.parse(url));

    test('maps website pages onto app screens', () {
      expect(map('https://margapp.in/routes/char-dham?ref=AB12'), '/routes/view/char-dham');
      expect(map('https://margapp.in/cards/0193f2a1-7c4e-7a10-9d3b-1f2e3d4c5b6a'), '/cards/view/0193f2a1-7c4e-7a10-9d3b-1f2e3d4c5b6a');
      expect(map('https://margapp.in/festivals/diwali'), '/knowledge/festivals/diwali');
      expect(map('https://margapp.in/blogs/story-of-kashi'), '/knowledge/blogs/story-of-kashi');
      expect(map('https://margapp.in/invite/MARG1088'), '/');
    });

    test('drops the Hindi prefix', () {
      expect(map('https://margapp.in/hi/temples/kashi-vishwanath'), '/temples/kashi-vishwanath');
      expect(map('https://margapp.in/hi/routes/char-dham'), '/routes/view/char-dham');
      expect(map('https://margapp.in/hi'), '/');
    });

    test('leaves app paths and same-path pages alone', () {
      expect(map('/temples/kashi-vishwanath?ref=AB12'), isNull);
      expect(map('/routes/discover'), isNull);
      expect(map('/routes/view/char-dham'), isNull);
      expect(map('/cards/gallery'), isNull);
      expect(map('/passport/timeline'), isNull);
    });
  });

  test('reads the referral code from an invite or a tagged share', () {
    expect(referralCodeOfWebLink(Uri.parse('https://margapp.in/invite/MARG1088')), 'MARG1088');
    expect(referralCodeOfWebLink(Uri.parse('https://margapp.in/hi/invite/MARG1088')), 'MARG1088');
    expect(referralCodeOfWebLink(Uri.parse('https://margapp.in/temples/x?ref=AB12&utm_source=app_share')), 'AB12');
    expect(referralCodeOfWebLink(Uri.parse('https://margapp.in/temples/x?ref=<bad>')), isNull);
    expect(referralCodeOfWebLink(Uri.parse('/temples/x')), isNull);
  });

  group('ReferralAttribution', () {
    final joinedToday = DateTime(2026, 10, 15);
    final now = DateTime(2026, 10, 15, 12);

    test('the install referrer code is applied once to a new account', () async {
      final store = _MemoryStore();
      final remote = _Remote();
      final a = ReferralAttribution(
        store: store,
        remote: remote,
        installReferrer: const _Referrer('utm_source=margapp.in&utm_medium=invite&ref=MARG1088'),
      );
      await a.captureInstallReferrer();
      await a.applyPending(joinedAt: joinedToday, now: now);
      await a.applyPending(joinedAt: joinedToday, now: now);
      expect(remote.applied, [('MARG1088', 'play_install')]);
    });

    test('the first code wins over a later link', () async {
      final store = _MemoryStore();
      final remote = _Remote();
      final a = ReferralAttribution(store: store, remote: remote, installReferrer: const _Referrer(null));
      await a.remember('FIRST1', source: 'link');
      await a.remember('SECOND', source: 'link');
      await a.applyPending(joinedAt: joinedToday, now: now);
      expect(remote.applied.single.$1, 'FIRST1');
    });

    test('an existing account is never credited', () async {
      final store = _MemoryStore();
      final remote = _Remote();
      final a = ReferralAttribution(store: store, remote: remote, installReferrer: const _Referrer(null));
      await a.remember('MARG1088', source: 'link');
      await a.applyPending(joinedAt: DateTime(2026, 1, 1), now: now);
      expect(remote.applied, isEmpty);
      expect(store.values, isEmpty);
    });

    test('keeps the code when offline, drops it when the server refuses', () async {
      final store = _MemoryStore();
      final offline = ReferralAttribution(
        store: store,
        remote: _Remote(fail: DioException(requestOptions: RequestOptions())),
        installReferrer: const _Referrer(null),
      );
      await offline.remember('MARG1088', source: 'link');
      await offline.applyPending(joinedAt: joinedToday, now: now);
      expect(store.values['referral.pendingCode'], 'MARG1088');

      final refused = ReferralAttribution(
        store: store,
        remote: _Remote(
          fail: DioException(
            requestOptions: RequestOptions(),
            response: Response(requestOptions: RequestOptions(), statusCode: 409),
          ),
        ),
        installReferrer: const _Referrer(null),
      );
      await refused.applyPending(joinedAt: joinedToday, now: now);
      expect(store.values.containsKey('referral.pendingCode'), isFalse);
    });
  });
}
