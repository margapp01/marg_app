import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:marg_app/shared/maps/arc_path.dart';

void main() {
  test('each hop becomes a sampled arc that keeps every stop', () {
    const stops = [LatLng(25.3, 83.0), LatLng(27.2, 78.0), LatLng(28.6, 77.2)];
    final arc = ArcPath.geo(stops);

    expect(arc.length, 1 + 2 * ArcPath.samples);
    expect(arc.first, stops[0]);
    expect(arc[ArcPath.samples].latitude, closeTo(stops[1].latitude, 1e-9));
    expect(arc[ArcPath.samples].longitude, closeTo(stops[1].longitude, 1e-9));
    expect(arc.last.latitude, closeTo(stops[2].latitude, 1e-9));
  });

  test('a due-east hop bows north (left of travel), not straight', () {
    final arc = ArcPath.geo(const [LatLng(20, 75), LatLng(20, 80)]);
    final mid = arc[ArcPath.samples ~/ 2];
    expect(mid.latitude, greaterThan(20.2));
  });

  test('fewer than two stops pass through unchanged', () {
    expect(ArcPath.geo(const [LatLng(20, 75)]), hasLength(1));
  });

  test('dashing a path yields gaps (shorter total than the source)', () {
    final source = ArcPath.screen(const [Offset.zero, Offset(100, 0)]);
    final full = source.computeMetrics().fold<double>(0, (s, m) => s + m.length);
    final dashed = ArcPath.dashed(source).computeMetrics().fold<double>(0, (s, m) => s + m.length);
    expect(dashed, lessThan(full * 0.7));
    expect(dashed, greaterThan(full * 0.5));
  });

  test('the arrow at a hop\'s middle points the way of travel', () {
    final east = ArcPath.midpoint(const LatLng(20, 75), const LatLng(20, 80));
    expect(east.angle.abs(), lessThan(0.2));
    final south = ArcPath.midpoint(const LatLng(25, 78), const LatLng(15, 78));
    expect(south.angle, closeTo(1.5708, 0.25));
    expect(east.point.longitude, closeTo(77.5, 0.05));
  });

  test('the trail joins neighbours instead of zig-zagging in list order', () {
    // Four stops along a meridian, listed out of order.
    const stops = [LatLng(10, 77), LatLng(30, 77), LatLng(15, 77), LatLng(25, 77)];
    final order = ArcPath.trailOrder(stops);
    expect(order.toSet(), {0, 1, 2, 3});
    final lats = [for (final i in order) stops[i].latitude];
    final ascending = [...lats]..sort();
    expect(lats, anyOf([equals(ascending), equals(ascending.reversed.toList())]));
  });
}
