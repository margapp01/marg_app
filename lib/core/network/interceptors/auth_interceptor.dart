import 'dart:async';

import 'package:dio/dio.dart';

import '../../auth/auth_tokens.dart';
import '../../auth/token_store.dart';

/// Refreshes the token pair given the current refresh token, or returns null
/// if the session can no longer be refreshed. Implemented by the auth feature
/// and injected in bootstrap, so core stays independent of features.
typedef TokenRefresher = Future<AuthTokens?> Function(String refreshToken);

/// Attaches the Marg access token to every request and transparently refreshes
/// it once on a 401, retrying the original request. Refreshes are single-flight
/// (concurrent 401s share one refresh). On refresh failure the session is
/// cleared and [onSessionExpired] fires so the app can route to sign-in.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStore tokenStore,
    required TokenRefresher refresher,
    required Dio retryDio,
    this.onSessionExpired,
  })  : _tokens = tokenStore,
        _refresher = refresher,
        _retryDio = retryDio;

  final TokenStore _tokens;
  final TokenRefresher _refresher;
  final Dio _retryDio; // bare Dio (no interceptor) for retrying
  final void Function()? onSessionExpired;

  Future<AuthTokens?>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey('Authorization')) {
      final tokens = await _tokens.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['__retried'] == true;
    final hadAuth = err.requestOptions.headers.containsKey('Authorization');

    if (!is401 || alreadyRetried || !hadAuth) {
      return handler.next(err);
    }

    final refreshed = await _refreshOnce();
    if (refreshed == null) {
      onSessionExpired?.call();
      return handler.next(err);
    }

    try {
      final req = err.requestOptions
        ..headers['Authorization'] = 'Bearer ${refreshed.accessToken}'
        ..extra['__retried'] = true;
      final res = await _retryDio.fetch<dynamic>(req);
      return handler.resolve(res);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  Future<AuthTokens?> _refreshOnce() {
    return _refreshing ??= () async {
      try {
        final current = await _tokens.read();
        if (current == null) return null;
        final next = await _refresher(current.refreshToken);
        if (next == null) {
          await _tokens.clear();
          return null;
        }
        await _tokens.save(next);
        return next;
      } catch (_) {
        await _tokens.clear();
        return null;
      } finally {
        _refreshing = null;
      }
    }();
  }
}
