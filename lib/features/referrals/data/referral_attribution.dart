import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/install_referrer_service.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/shared_prefs_store.dart';
import 'datasource/referral_remote_datasource.dart';

/// Credits the friend who brought a new pilgrim to MARG.
///
/// A referral code arrives with the install (the Play install referrer set by
/// a margapp.in invite page) or with a shared link opened before signing in.
/// It waits on the device until the pilgrim is signed in, then is applied
/// once — and only to a new account (onboarded within [newAccountWindow]), so
/// an existing pilgrim opening a friend's link is never counted as referred.
/// The backend rejects self, duplicate and looped referrals; any such answer
/// clears the code, while a network failure keeps it for next launch.
class ReferralAttribution {
  ReferralAttribution({
    required KeyValueStore store,
    required ReferralRemoteDataSource remote,
    required InstallReferrerService installReferrer,
  })  : _store = store,
        _remote = remote,
        _installReferrer = installReferrer;

  final KeyValueStore _store;
  final ReferralRemoteDataSource _remote;
  final InstallReferrerService _installReferrer;

  static const _codeKey = 'referral.pendingCode';
  static const _sourceKey = 'referral.pendingSource';
  static const _installCheckedKey = 'referral.installReferrerChecked';
  static final _codePattern = RegExp(r'^[A-Za-z0-9_-]{4,32}$');

  /// How recently an account must have joined for a referral to count.
  static const Duration newAccountWindow = Duration(days: 7);

  /// [value] when it is a well-formed referral code, else null.
  static String? codeFrom(String? value) => value != null && _codePattern.hasMatch(value) ? value : null;

  /// Keeps [code] for later. The first code wins: a later link never
  /// replaces the friend whose invite brought the install.
  Future<void> remember(String code, {required String source}) async {
    if (codeFrom(code) == null || await _store.getString(_codeKey) != null) return;
    await _store.setString(_codeKey, code);
    await _store.setString(_sourceKey, source);
  }

  /// Reads the install referrer once per install and keeps its `ref` code.
  Future<void> captureInstallReferrer() async {
    if (await _store.getBool(_installCheckedKey) == true) return;
    final raw = await _installReferrer.read();
    await _store.setBool(_installCheckedKey, value: true);
    if (raw == null) return;
    String? code;
    try {
      code = codeFrom(Uri.splitQueryString(raw)['ref']);
    } on FormatException {
      code = null;
    }
    if (code != null) await remember(code, source: 'play_install');
  }

  /// Applies a kept code for the signed-in pilgrim who [joinedAt] (finished
  /// onboarding); an older account just drops it.
  Future<void> applyPending({required DateTime? joinedAt, DateTime? now}) async {
    final code = await _store.getString(_codeKey);
    if (code == null) return;
    final isNew = joinedAt != null && (now ?? DateTime.now()).difference(joinedAt) <= newAccountWindow;
    if (!isNew) return _clear();
    try {
      await _remote.apply(code, source: await _store.getString(_sourceKey));
    } on DioException catch (e) {
      if (e.response == null) return; // offline — try again next launch
    } catch (_) {
      return;
    }
    await _clear();
  }

  Future<void> _clear() async {
    await _store.remove(_codeKey);
    await _store.remove(_sourceKey);
  }
}

final referralAttributionProvider = Provider<ReferralAttribution>(
  (ref) => ReferralAttribution(
    store: ref.watch(keyValueStoreProvider),
    remote: ref.watch(referralRemoteDataSourceProvider),
    installReferrer: ref.watch(installReferrerServiceProvider),
  ),
);
