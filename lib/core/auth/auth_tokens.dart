/// The Marg access/refresh token pair. Cross-cutting: persisted by
/// [TokenStore] and consumed by the network auth interceptor, so it lives in
/// core rather than the auth feature.
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}
