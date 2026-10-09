import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_tokens.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/firebase_auth_result.dart';

/// Talks to the backend `/auth/*` endpoints. Uses the bare Dio (no Marg-access
/// interceptor) because these calls carry no token, a Firebase token, or a
/// refresh token — never the Marg access token via the interceptor.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Map<String, dynamic> _data(Response<dynamic> res) =>
      (res.data as Map)['data'] as Map<String, dynamic>;

  Future<FirebaseAuthResult> firebase(String idToken) async {
    final res = await _dio.post<dynamic>(
      '/auth/firebase',
      data: {'idToken': idToken},
    );
    return FirebaseAuthResult.fromJson(_data(res));
  }

  Future<({AuthUser user, AuthTokens tokens})> completeRegistration({
    required String firebaseIdToken,
    required String mobile,
    String? name,
    String? profilePhoto,
  }) async {
    final res = await _dio.post<dynamic>(
      '/auth/complete-registration',
      data: {'mobile': mobile, 'name': ?name, 'profilePhoto': ?profilePhoto},
      options: Options(headers: {'Authorization': 'Bearer $firebaseIdToken'}),
    );
    final data = _data(res);
    return (
      user: AuthUser.fromJson((data['user'] as Map).cast<String, dynamic>()),
      tokens: AuthTokens.fromJson(
        (data['tokens'] as Map).cast<String, dynamic>(),
      ),
    );
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    final res = await _dio.post<dynamic>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return AuthTokens.fromJson(
      (_data(res)['tokens'] as Map).cast<String, dynamic>(),
    );
  }

  Future<AuthUser> me(String accessToken) async => AuthUser.fromJson(await meJson(accessToken));

  /// The raw `/auth/me` user map (cached for offline session restore). The
  /// backend wraps it as `data: { user }`.
  Future<Map<String, dynamic>> meJson(String accessToken) async {
    final res = await _dio.get<dynamic>(
      '/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return (_data(res)['user'] as Map).cast<String, dynamic>();
  }

  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _dio.post<dynamic>(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(bareDioProvider)),
);
