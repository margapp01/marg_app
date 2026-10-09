import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../app/constants/brand_assets.dart';
import 'detailed_boundaries.dart';

/// One polygon of a boundary: its outer ring plus any holes.
class BoundaryShape {
  const BoundaryShape(this.outer, [this.holes = const []]);

  final List<LatLng> outer;
  final List<List<LatLng>> holes;
}

/// The two outlines drawn on every map: Akhand Bharat (including Tibet) and
/// Bharat (the official India boundary).
///
/// Shapes are ordered largest-first, so `akhandBharat.first` is the mainland.
class BharatBoundaries {
  const BharatBoundaries({required this.akhandBharat, required this.india});

  final List<BoundaryShape> akhandBharat;
  final List<BoundaryShape> india;

  /// Parses [BrandAssets.bharatBoundaries] — a FeatureCollection whose
  /// features carry `properties.id` of `akhandBharat` or `india`.
  static BharatBoundaries parse(String raw) {
    final features = ((jsonDecode(raw) as Map)['features'] as List).cast<Map<String, dynamic>>();
    List<BoundaryShape> shapesOf(String id) {
      final feature = features.firstWhere((f) => (f['properties'] as Map)['id'] == id);
      final geometry = (feature['geometry'] as Map).cast<String, dynamic>();
      final coordinates = geometry['coordinates'] as List<dynamic>;
      final polygons = geometry['type'] == 'Polygon' ? [coordinates] : coordinates.cast<List<dynamic>>();
      final shapes = [
        for (final rings in polygons)
          BoundaryShape(
            _ring(rings.first as List<dynamic>),
            [for (final hole in rings.skip(1)) _ring(hole as List<dynamic>)],
          ),
      ]..sort((a, b) => b.outer.length.compareTo(a.outer.length));
      return shapes;
    }

    return BharatBoundaries(akhandBharat: shapesOf('akhandBharat'), india: shapesOf('india'));
  }

  // GeoJSON positions are [longitude, latitude].
  static List<LatLng> _ring(List<dynamic> coords) => [
        for (final c in coords.cast<List<dynamic>>()) LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
      ];
}

/// Loaded once and kept for the app's lifetime; parsed off the UI isolate.
/// Prefers the downloaded detailed outline, falling back to the bundled one.
final bharatBoundariesProvider = FutureProvider<BharatBoundaries>((ref) async {
  final detailed = await ref.read(detailedBoundariesStoreProvider).readOrNull();
  if (detailed != null) {
    try {
      return await compute(BharatBoundaries.parse, detailed);
    } catch (_) {/* a damaged download falls back to the bundled outline */}
  }
  final raw = await rootBundle.loadString(BrandAssets.bharatBoundaries);
  return compute(BharatBoundaries.parse, raw);
});
