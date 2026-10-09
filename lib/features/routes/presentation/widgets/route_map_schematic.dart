import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/route_detail_bundle.dart';

/// A self-painted schematic of a route: temple markers plotted from their real
/// latitude/longitude (normalised to the canvas) joined by a polyline, coloured
/// by completion. This is an honest schematic — NOT a street map (the app has
/// no map-tile SDK). Completed hops are highlighted; the current temple pulses.
class RouteMapSchematic extends StatelessWidget {
  const RouteMapSchematic({required this.bundle, this.height = 300, super.key});

  final RouteDetailBundle bundle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final points = bundle.route.temples
        .where((t) => !(t.temple.latitude == 0 && t.temple.longitude == 0))
        .toList(growable: false);

    if (points.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(l10n.ryMapUnavailable,
              style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary)),
        ),
      );
    }

    final statuses = {for (final e in points) e.temple.id: bundle.statusOf(e)};

    return Column(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: context.colors.sky.withValues(alpha: 0.12),
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: context.colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.infinite,
              painter: _RouteMapPainter(
                lats: [for (final e in points) e.temple.latitude],
                lngs: [for (final e in points) e.temple.longitude],
                statuses: [for (final e in points) statuses[e.temple.id]!],
                line: context.scheme.primary,
                completed: context.colors.success,
                current: context.scheme.primary,
                upcoming: context.colors.textDisabled,
                surface: context.scheme.surface,
              ),
            ),
          ),
        ),
        const Gap(AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            _LegendDot(color: context.colors.success, label: l10n.ryStatusCompleted),
            _LegendDot(color: context.scheme.primary, label: l10n.ryStatusCurrent),
            _LegendDot(color: context.colors.textDisabled, label: l10n.ryStatusUpcoming),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const Gap(AppSpacing.xxs),
        Text(label, style: context.caption.copyWith(color: context.colors.textSecondary)),
      ],
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  _RouteMapPainter({
    required this.lats,
    required this.lngs,
    required this.statuses,
    required this.line,
    required this.completed,
    required this.current,
    required this.upcoming,
    required this.surface,
  });

  final List<double> lats;
  final List<double> lngs;
  final List<TempleJourneyStatus> statuses;
  final Color line;
  final Color completed;
  final Color current;
  final Color upcoming;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 32.0;
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);
    final spanLat = (maxLat - minLat).abs() < 1e-6 ? 1.0 : (maxLat - minLat);
    final spanLng = (maxLng - minLng).abs() < 1e-6 ? 1.0 : (maxLng - minLng);

    Offset project(int i) {
      // Longitude → x, latitude → y (inverted: north is up).
      final x = pad + (lngs[i] - minLng) / spanLng * (size.width - 2 * pad);
      final y = pad + (maxLat - lats[i]) / spanLat * (size.height - 2 * pad);
      return Offset(x, y);
    }

    final offsets = [for (var i = 0; i < lats.length; i++) project(i)];

    // Dashed connecting polyline.
    final linePaint = Paint()
      ..color = line.withValues(alpha: 0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    for (var i = 1; i < offsets.length; i++) {
      _dashLine(canvas, offsets[i - 1], offsets[i], linePaint);
    }

    // Markers.
    for (var i = 0; i < offsets.length; i++) {
      final c = switch (statuses[i]) {
        TempleJourneyStatus.completed => completed,
        TempleJourneyStatus.current => current,
        TempleJourneyStatus.remaining => upcoming,
      };
      final o = offsets[i];
      if (statuses[i] == TempleJourneyStatus.current) {
        canvas.drawCircle(o, 12, Paint()..color = c.withValues(alpha: 0.25));
      }
      canvas.drawCircle(o, 7, Paint()..color = surface);
      canvas.drawCircle(o, 6, Paint()..color = c);
    }
  }

  void _dashLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 6.0, gap = 4.0;
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final start = a + dir * d;
      final end = a + dir * (d + dash).clamp(0, total).toDouble();
      canvas.drawLine(start, end, paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_RouteMapPainter old) => old.statuses != statuses || old.lats != lats;
}
