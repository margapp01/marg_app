/// Domain-level failure hierarchy. Use cases and controllers deal in
/// [Failure]s — never raw exceptions — so the UI can map each variant to
/// user-facing copy.
sealed class Failure {
  const Failure(this.message, {this.code});

  /// Log-safe description; NOT for direct display (screens localize).
  final String message;

  /// Stable machine-readable code.
  final String? code;
}

/// Connectivity, timeouts, or non-2xx API responses.
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, this.statusCode});

  /// HTTP status when the server responded; null for transport errors.
  final int? statusCode;
}

/// Input rejected by local rules or the server's validation layer.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, this.fieldErrors = const {}});

  /// Per-field messages, keyed by field name.
  final Map<String, String> fieldErrors;
}

/// Anything unclassified — the safety net.
final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code, this.cause});

  final Object? cause;
}
