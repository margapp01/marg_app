import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/repository/google_auth_service.dart';
import '../states/auth_state.dart';

/// Drives the auth lifecycle for the UI: Google sign-in, mobile completion,
/// session restore, and sign-out. Reads [AuthRepository] for the work and
/// exposes an [AuthState] the router/pages react to.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.unknown();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Restore a stored session on launch.
  Future<void> restore() async {
    final user = await _repo.restoreSession();
    state = user == null
        ? const AuthState(status: AuthStatus.unauthenticated)
        : AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState(status: AuthStatus.authenticating);
    try {
      final result = await _repo.signInWithGoogle();
      if (!result.requiresMobile && result.user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: result.user);
      } else {
        state = AuthState(
          status: AuthStatus.needsMobile,
          googleProfile: result.profile,
        );
      }
    } on GoogleSignInFailure catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.cancelled ? null : e.message,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        error: 'Sign-in failed. Please try again.',
      );
    }
  }

  /// Attach the mobile number and finish the account. Rethrows on failure so
  /// the onboarding form can surface field errors (e.g. mobile already in use).
  Future<void> completeRegistration({
    required String mobile,
    String? name,
    String? profilePhoto,
  }) async {
    final user = await _repo.completeRegistration(
      mobile: mobile,
      name: name,
      profilePhoto: profilePhoto,
    );
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  /// Mark the session authenticated with an already-fetched user (e.g. the
  /// onboarding flow finishing with the finalised user in hand).
  void setAuthenticated(AuthUser user) {
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  /// Re-fetch the user (e.g. after onboarding completes).
  Future<void> refreshUser() async {
    final user = await _repo.currentUser();
    if (user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
