import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/token_store.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/firebase_auth_result.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/repository/google_auth_service.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required GoogleAuthService google,
    required TokenStore tokens,
  })  : _remote = remote,
        _google = google,
        _tokens = tokens;

  final AuthRemoteDataSource _remote;
  final GoogleAuthService _google;
  final TokenStore _tokens;

  @override
  Future<FirebaseAuthResult> signInWithGoogle() async {
    final idToken = await _google.signInAndGetIdToken();
    final result = await _remote.firebase(idToken);
    if (!result.requiresMobile && result.tokens != null) {
      await _tokens.save(result.tokens!);
    }
    return result;
  }

  @override
  Future<AuthUser> completeRegistration({
    required String mobile,
    String? name,
    String? profilePhoto,
  }) async {
    final idToken = await _google.currentIdToken();
    if (idToken == null) {
      throw const GoogleSignInFailure('Your session expired. Please sign in again.');
    }
    final res = await _remote.completeRegistration(
      firebaseIdToken: idToken,
      mobile: mobile,
      name: name,
      profilePhoto: profilePhoto,
    );
    await _tokens.save(res.tokens);
    return res.user;
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final tokens = await _tokens.read();
    if (tokens == null) return null;
    try {
      return await _fetchMe(tokens.accessToken);
    } on DioException catch (e) {
      // Offline / server unreachable: keep the session, use the cached profile.
      if (!_rejected(e)) return _cachedUser();
    } catch (_) {
      // Malformed profile — fall through to a refresh.
    }
    try {
      final next = await _remote.refresh(tokens.refreshToken);
      await _tokens.save(next);
      return await _fetchMe(next.accessToken);
    } on DioException catch (e) {
      if (!_rejected(e)) return _cachedUser();
      await _tokens.clear();
      return null;
    } catch (_) {
      await _tokens.clear();
      return null;
    }
  }

  /// The server answered and refused the credentials (vs. a network failure).
  static bool _rejected(DioException e) {
    final status = e.response?.statusCode;
    return status != null && status >= 400 && status < 500;
  }

  Future<AuthUser> _fetchMe(String accessToken) async {
    final json = await _remote.meJson(accessToken);
    await _tokens.saveUserJson(jsonEncode(json));
    return AuthUser.fromJson(json);
  }

  Future<AuthUser?> _cachedUser() async {
    final raw = await _tokens.readUserJson();
    if (raw == null) return null;
    try {
      return AuthUser.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthUser?> currentUser() async {
    final tokens = await _tokens.read();
    if (tokens == null) return null;
    try {
      return await _remote.me(tokens.accessToken);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    final tokens = await _tokens.read();
    if (tokens != null) {
      try {
        await _remote.logout(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
      } catch (_) {/* best effort */}
    }
    await _tokens.clear();
    await _google.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    google: ref.watch(googleAuthServiceProvider),
    tokens: ref.watch(tokenStoreProvider),
  );
});
