import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

/// A soft line chart for activity over time (e.g. monthly visits): a smooth
/// curve over a fading wash, faint guide lines, a dot and count per point and
/// the period labels underneath. Shows [emptyMessage] when every value is 0.
class TrendChart extends StatelessWidget {
  const TrendChart({
    required this.points,
    required this.emptyMessage,
    this.color,
    this.height = defaultHeight,
    super.key,
  });

  /// (label, value) pairs, oldest → newest.
  final List<(String, int)> points;
  final String emptyMessage;

  /// Line colour (defaults to saffron).
  final Color? color;
  final double height;

  static const double defaultHeight = 176;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.textSecondary;
    if (points.isEmpty || points.every((p) => p.$2 == 0)) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(emptyMessage, textAlign: TextAlign.center, style: context.caption.copyWith(color: muted)),
        ),
      );
    }
    return Semantics(
      label: points.map((p) => '${p.$1}: ${p.$2}').join(', '),
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendPainter(
              points: points,
              color: color ?? context.scheme.primary,
              grid: context.colors.divider,
              dotFill: context.colors.card,
              labelStyle: context.overline.copyWith(color: muted),
              valueStyle: context.caption.semiBold.withColor(context.scheme.secondary),
              textDirection: Directionality.of(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.color,
    required this.grid,
    required this.dotFill,
    required this.labelStyle,
    required this.valueStyle,
    required this.textDirection,
  });

  final List<(String, int)> points;
  final Color color;
  final Color grid;
  final Color dotFill;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final TextDirection textDirection;

  static const double _top = 22; // room for the value over the peak
  static const double _bottom = 22; // room for the period labels
  static const double _side = 14;
  static const int _guides = 3;

  TextPainter _text(String s, TextStyle style) =>
      TextPainter(text: TextSpan(text: s, style: style), textDirection: textDirection)..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(_side, _top, size.width - _side, size.height - _bottom);
    final max = points.fold<int>(1, (m, p) => p.$2 > m ? p.$2 : m);
    final step = points.length > 1 ? chart.width / (points.length - 1) : 0.0;
    final pts = [
      for (var i = 0; i < points.length; i++)
        Offset(
          points.length > 1 ? chart.left + step * i : chart.center.dx,
          chart.bottom - chart.height * points[i].$2 / max,
        ),
    ];

    final guide = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var g = 0; g <= _guides; g++) {
      final y = chart.bottom - chart.height * g / _guides;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), guide);
    }

    // Smooth curve: cubic segments with horizontal tangents (no overshoot).
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1];
      final b = pts[i];
      final mid = (a.dx + b.dx) / 2;
      line.cubicTo(mid, a.dy, mid, b.dy, b.dx, b.dy);
    }
    final area = Path.from(line)
      ..lineTo(pts.last.dx, chart.bottom)
      ..lineTo(pts.first.dx, chart.bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.02)],
        ).createShader(chart),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < pts.length; i++) {
      final p = pts[i];
      final last = i == pts.length - 1;
      canvas.drawCircle(p, last ? 5.5 : 4, Paint()..color = last ? color : dotFill);
      canvas.drawCircle(
        p,
        last ? 5.5 : 4,
        Paint()
          ..color = last ? dotFill : color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final value = points[i].$2;
      if (value > 0) {
        final v = _text('$value', valueStyle);
        v.paint(canvas, Offset(p.dx - v.width / 2, p.dy - v.height - 6));
      }
      final l = _text(points[i].$1, labelStyle);
      l.paint(canvas, Offset(p.dx - l.width / 2, chart.bottom + 6));
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.points != points || old.color != color || old.grid != grid || old.valueStyle != valueStyle;
}
