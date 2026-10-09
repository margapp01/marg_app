/// Base type for exceptions raised inside the app's own layers (data
/// sources, mappers, services). Infra code throws [AppException]s;
/// repositories translate them into [Failure]s at the domain boundary.
class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  /// Human-readable, log-safe description.
  final String message;

  /// Stable machine-readable code (e.g. 'NETWORK_TIMEOUT').
  final String? code;

  /// The underlying error, when wrapping one.
  final Object? cause;

  @override
  String toString() => 'AppException(${code ?? 'UNKNOWN'}: $message)';
}
