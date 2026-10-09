import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_store.dart';
import 'auth_tokens.dart';

/// Persists the Marg token pair in encrypted at-rest storage (Keychain /
/// Keystore). The access token is short-lived; the refresh token is the
/// session anchor used to restore on launch.
class TokenStore {
  TokenStore(this._store);

  final SecureStore _store;

  static const _accessKey = 'auth.accessToken';
  static const _refreshKey = 'auth.refreshToken';

  /// Last known `/auth/me` payload, so a launch without connectivity can
  /// restore the session instead of signing the devotee out.
  static const _userKey = 'auth.user';

  AuthTokens? _cache;

  Future<AuthTokens?> read() async {
    if (_cache != null) return _cache;
    final access = await _store.read(_accessKey);
    final refresh = await _store.read(_refreshKey);
    if (access == null || refresh == null) return null;
    return _cache = AuthTokens(accessToken: access, refreshToken: refresh);
  }

  Future<void> save(AuthTokens tokens) async {
    _cache = tokens;
    await _store.write(_accessKey, tokens.accessToken);
    await _store.write(_refreshKey, tokens.refreshToken);
  }

  Future<String?> readUserJson() => _store.read(_userKey);

  Future<void> saveUserJson(String json) => _store.write(_userKey, json);

  Future<void> clear() async {
    _cache = null;
    await _store.delete(_accessKey);
    await _store.delete(_refreshKey);
    await _store.delete(_userKey);
  }
}

final tokenStoreProvider =
    Provider<TokenStore>((ref) => TokenStore(ref.watch(secureStoreProvider)));
