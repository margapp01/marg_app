import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runtime permissions (permission_handler). Central place for request
/// flows + rationale, so screens never call the plugin directly.
///
/// Foundation seam: dependency-injected via Riverpod now, implemented in its
/// feature phase. No behaviour yet by design.
class PermissionService {
  const PermissionService();
}

final permissionServiceProvider = Provider<PermissionService>((ref) => const PermissionService());
