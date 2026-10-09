import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/localization/locale_provider.dart';
import '../../../directions/data/directions_api.dart';
import '../../../directions/domain/route_plan.dart';

typedef VisitRouteQuery = ({LatLng from, LatLng to, TravelMode mode});

/// The road route shown on the Navigation step — the same router (so the
/// same distance and time) as the in-app Directions screen.
final visitRouteProvider = FutureProvider.autoDispose.family<RoutePlan, VisitRouteQuery>((ref, q) {
  final language = ref.read(localeControllerProvider)?.languageCode ?? 'en';
  return ref.watch(directionsApiProvider).route(q.from, q.to, q.mode, language: language);
});
