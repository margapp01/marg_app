import '../../../../core/auth/auth_tokens.dart';
import 'auth_user.dart';

/// The Google claims surfaced before mobile completion (name/email/photo).
class GoogleProfile {
  const GoogleProfile({this.name, this.email, this.photo});

  final String? name;
  final String? email;
  final String? photo;

  factory GoogleProfile.fromJson(Map<String, dynamic> json) => GoogleProfile(
        name: json['name'] as String?,
        email: json['email'] as String?,
        photo: json['photo'] as String?,
      );
}

/// Result of `POST /auth/firebase`: either issues [tokens]+[user] (returning
/// active user) or signals [requiresMobile] with the Google [profile].
class FirebaseAuthResult {
  const FirebaseAuthResult({
    required this.isNewUser,
    required this.requiresMobile,
    required this.firebaseUid,
    required this.profile,
    this.tokens,
    this.user,
  });

  final bool isNewUser;
  final bool requiresMobile;
  final String firebaseUid;
  final GoogleProfile profile;
  final AuthTokens? tokens;
  final AuthUser? user;

  factory FirebaseAuthResult.fromJson(Map<String, dynamic> json) => FirebaseAuthResult(
        isNewUser: (json['isNewUser'] as bool?) ?? false,
        requiresMobile: (json['requiresMobile'] as bool?) ?? false,
        firebaseUid: json['firebaseUid'] as String,
        profile: GoogleProfile.fromJson(
          (json['profile'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        tokens: json['tokens'] == null
            ? null
            : AuthTokens.fromJson((json['tokens'] as Map).cast<String, dynamic>()),
        user: json['user'] == null
            ? null
            : AuthUser.fromJson((json['user'] as Map).cast<String, dynamic>()),
      );
}
