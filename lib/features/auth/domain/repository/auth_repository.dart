import '../entities/auth_user.dart';
import '../entities/firebase_auth_result.dart';

/// Auth operations the presentation layer depends on. The implementation
/// orchestrates Google sign-in, the backend `/auth/*` endpoints, and token
/// storage. The provider is exposed by the data layer's implementation.
abstract interface class AuthRepository {
  /// Google sign-in → `POST /auth/firebase`. Persists tokens when the account
  /// is already complete; otherwise the result carries [requiresMobile].
  Future<FirebaseAuthResult> signInWithGoogle();

  /// `POST /auth/complete-registration` — attach mobile, persist tokens.
  Future<AuthUser> completeRegistration({
    required String mobile,
    String? name,
    String? profilePhoto,
  });

  /// Restore a stored session (refreshing if needed). Null when unauthenticated.
  Future<AuthUser?> restoreSession();

  /// Re-fetch `/auth/me` with the stored access token.
  Future<AuthUser?> currentUser();

  Future<void> signOut();
}
