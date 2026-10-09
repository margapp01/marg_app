import 'package:flutter_riverpod/flutter_riverpod.dart';

/// System share sheet (share_plus) for passport/cards sharing.
///
/// Foundation seam: dependency-injected via Riverpod now, implemented in its
/// feature phase. No behaviour yet by design.
class ShareService {
  const ShareService();
}

final shareServiceProvider = Provider<ShareService>((ref) => const ShareService());
