import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/core/auth/auth_tokens.dart';
import 'package:marg_app/core/auth/token_store.dart';
import 'package:marg_app/core/storage/secure_store.dart';
import 'package:marg_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:marg_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:marg_app/features/auth/domain/repository/google_auth_service.dart';

class _MemoryStore implements SecureStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _NoGoogle implements GoogleAuthService {
  @override
  Future<String?> currentIdToken() async => null;

  @override
  Future<String> signInAndGetIdToken() => throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}

/// Answers every request with [respond] (a status + body) or throws a
/// connection error when [offline].
class _Adapter implements HttpClientAdapter {
  _Adapter({this.offline = false, this.status = 200});

  final bool offline;
  final int status;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    if (offline) {
      throw DioException.connectionError(requestOptions: options, reason: 'offline');
    }
    final body = status == 200
        ? {
            'success': true,
            'message': 'ok',
            'data': {
              'user': {'id': 'u1', 'name': 'Aarav'},
            },
          }
        : {'success': false, 'message': 'Unauthorized', 'errors': <Object>[]};
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Future<(AuthRepositoryImpl, _MemoryStore)> _repo(_Adapter adapter, {String? cachedUser}) async {
  final store = _MemoryStore();
  final tokens = TokenStore(store);
  await tokens.save(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
  if (cachedUser != null) await tokens.saveUserJson(cachedUser);
  final dio = Dio()..httpClientAdapter = adapter;
  return (
    AuthRepositoryImpl(remote: AuthRemoteDataSource(dio), google: _NoGoogle(), tokens: tokens),
    store,
  );
}

void main() {
  group('restoreSession', () {
    test('online: restores the user and caches the profile', () async {
      final (repo, store) = await _repo(_Adapter());
      final user = await repo.restoreSession();
      expect(user?.name, 'Aarav');
      expect(store.values['auth.user'], isNotNull);
    });

    test('offline: keeps the session and restores the cached profile', () async {
      final (repo, store) = await _repo(_Adapter(offline: true), cachedUser: jsonEncode({'id': 'u1', 'name': 'Aarav'}));
      final user = await repo.restoreSession();
      expect(user?.id, 'u1');
      expect(store.values['auth.refreshToken'], 'r', reason: 'tokens must survive a network failure');
    });

    test('rejected credentials: signs out and clears everything', () async {
      final (repo, store) = await _repo(_Adapter(status: 401), cachedUser: jsonEncode({'id': 'u1'}));
      expect(await repo.restoreSession(), isNull);
      expect(store.values, isEmpty);
    });
  });
}
