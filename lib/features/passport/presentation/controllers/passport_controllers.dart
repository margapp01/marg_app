import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/passport_repository_impl.dart';
import '../../domain/entities/passport.dart';
import '../../domain/entities/passport_lists.dart';
import '../../domain/entities/passport_share.dart';
import '../../domain/entities/timeline_event.dart';

/// The dashboard bundle: overview + rank + referral.
final passportDashboardProvider = FutureProvider.autoDispose<PassportBundle>(
  (ref) => ref.watch(passportRepositoryProvider).dashboard(),
);

/// The merged journey timeline.
final passportTimelineProvider = FutureProvider.autoDispose<List<TimelineEvent>>(
  (ref) => ref.watch(passportRepositoryProvider).timeline(),
);

/// Verified visit coordinates for the map.
final passportVisitPointsProvider = FutureProvider.autoDispose<List<VisitPoint>>(
  (ref) => ref.watch(passportRepositoryProvider).visitPoints(),
);

final passportCardsProvider = FutureProvider.autoDispose<CardsSummary>(
  (ref) => ref.watch(passportRepositoryProvider).cards(),
);

final passportSeriesProvider = FutureProvider.autoDispose<List<PassportGroup>>(
  (ref) => ref.watch(passportRepositoryProvider).series(),
);

final passportSeasonsProvider = FutureProvider.autoDispose<List<PassportGroup>>(
  (ref) => ref.watch(passportRepositoryProvider).seasons(),
);

final passportTemplesProvider = FutureProvider.autoDispose<List<TempleHistoryItem>>(
  (ref) => ref.watch(passportRepositoryProvider).temples(),
);

final passportRoutesProvider = FutureProvider.autoDispose<List<RouteHistoryItem>>(
  (ref) => ref.watch(passportRepositoryProvider).routes(),
);

final passportShareProvider = FutureProvider.autoDispose<PassportShare>(
  (ref) => ref.watch(passportRepositoryProvider).share(),
);

/// Mints (or reuses) the public passport link — the QR/share target.
final passportShareLinkProvider = FutureProvider.autoDispose<String>(
  (ref) => ref.watch(passportRepositoryProvider).mintShareLink(),
);
