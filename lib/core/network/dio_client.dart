import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/app_config.dart';
import '../../app/constants/app_constants.dart';
import '../auth/token_store.dart';
import 'interceptors/auth_interceptor.dart';

/// Base Dio for the Marg API. Two flavours are exposed: [bareDioProvider]
/// (no auth interceptor — used for `/auth/*` and token refresh) and
/// [dioProvider] (adds the Bearer + refresh interceptor for authenticated
/// `/my/*` calls).
Dio buildDio(AppConfig config) {
  return Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: AppConstants.networkTimeout,
      receiveTimeout: AppConstants.networkTimeout,
      headers: const {'Accept': 'application/json'},
    ),
  );
}

/// No interceptors — safe for auth exchange, refresh, and interceptor retries.
final bareDioProvider = Provider<Dio>((ref) => buildDio(ref.watch(appConfigProvider)));

/// Refreshes the token pair. Overridden in `bootstrap` with the auth feature's
/// implementation so core does not depend on features.
final tokenRefresherProvider = Provider<TokenRefresher>(
  (ref) => throw UnimplementedError('tokenRefresherProvider must be overridden in bootstrap()'),
);

/// Authenticated Dio: attaches the access token and refreshes once on 401.
final dioProvider = Provider<Dio>((ref) {
  final dio = buildDio(ref.watch(appConfigProvider));
  dio.interceptors.add(
    AuthInterceptor(
      tokenStore: ref.watch(tokenStoreProvider),
      refresher: ref.watch(tokenRefresherProvider),
      retryDio: ref.watch(bareDioProvider),
    ),
  );
  return dio;
});
