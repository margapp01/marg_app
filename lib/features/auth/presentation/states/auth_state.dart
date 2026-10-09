import '../../domain/entities/auth_user.dart';
import '../../domain/entities/firebase_auth_result.dart';

enum AuthStatus {
  /// Not yet resolved (before session restore).
  unknown,
  authenticating,
  unauthenticated,

  /// Google-authenticated but the account isn't complete (needs mobile).
  needsMobile,
  authenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.googleProfile,
    this.error,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  final AuthStatus status;
  final AuthUser? user;
  final GoogleProfile? googleProfile;
  final String? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}
