import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/temple_detail_repository_impl.dart';
import '../../domain/entities/temple_detail.dart';

/// Loads the Temple Detail bundle for a slug. Auto-disposes per screen; retry
/// and pull-to-refresh use `ref.invalidate(templeDetailControllerProvider(slug))`.
final templeDetailControllerProvider =
    FutureProvider.autoDispose.family<TempleDetailBundle, String>((ref, slug) {
  return ref.watch(templeDetailRepositoryProvider).loadBundle(slug);
});
