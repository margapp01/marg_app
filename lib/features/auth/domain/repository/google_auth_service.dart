import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raised when Google sign-in is cancelled or fails before we get a token.
class GoogleSignInFailure implements Exception {
  const GoogleSignInFailure(this.message, {this.cancelled = false});
  final String message;
  final bool cancelled;
  @override
  String toString() => 'GoogleSignInFailure($message)';
}

/// Google sign-in contract. Yields a fresh Firebase **ID token** to exchange
/// with the backend at `POST /auth/firebase`. Kept Firebase-free so unit/widget
/// tests never pull the Firebase plugin into the host-VM compile; the concrete
/// implementation is injected in `bootstrap`.
abstract interface class GoogleAuthService {
  Future<String> signInAndGetIdToken();

  /// A fresh Firebase ID token for the current session (used by
  /// complete-registration after the initial exchange).
  Future<String?> currentIdToken();

  Future<void> signOut();
}

/// Overridden in `bootstrap` with the Firebase implementation.
final googleAuthServiceProvider = Provider<GoogleAuthService>(
  (ref) => throw UnimplementedError(
    'googleAuthServiceProvider must be overridden in bootstrap()',
  ),
);
