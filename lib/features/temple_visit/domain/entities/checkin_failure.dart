/// Why a check-in did not verify. The [message] is always the backend's own
/// message (never hardcoded); [kind] is a best-effort classification (from HTTP
/// status + message) used only to pick an icon and surface relevant guidance.
enum CheckinFailureKind {
  outOfGeofence,
  mockLocation,
  alreadyCheckedIn,
  notFound,
  rateLimited,
  offline,
  unknown,
}

class CheckinFailure implements Exception {
  const CheckinFailure({required this.message, this.statusCode, this.kind = CheckinFailureKind.unknown});

  /// Backend-provided, user-facing message.
  final String message;
  final int? statusCode;
  final CheckinFailureKind kind;

  /// Classify a server response. Marg's error envelope carries no machine code,
  /// so we key off HTTP status + the message text.
  factory CheckinFailure.fromResponse({int? statusCode, required String message}) {
    final m = message.toLowerCase();
    CheckinFailureKind kind;
    if (statusCode == 429) {
      kind = CheckinFailureKind.rateLimited;
    } else if (statusCode == 404) {
      kind = CheckinFailureKind.notFound;
    } else if (statusCode == 409 || m.contains('already')) {
      kind = CheckinFailureKind.alreadyCheckedIn;
    } else if (m.contains('mock')) {
      kind = CheckinFailureKind.mockLocation;
    } else if (m.contains('away') || m.contains('geofence') || m.contains('within')) {
      kind = CheckinFailureKind.outOfGeofence;
    } else {
      kind = CheckinFailureKind.unknown;
    }
    return CheckinFailure(message: message, statusCode: statusCode, kind: kind);
  }

  /// A transport/connectivity failure (no server verdict).
  const CheckinFailure.offline(this.message)
      : statusCode = null,
        kind = CheckinFailureKind.offline;

  @override
  String toString() => 'CheckinFailure($kind: $message)';
}
