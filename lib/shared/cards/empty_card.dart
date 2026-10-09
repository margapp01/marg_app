import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// A dashed placeholder slot — a locked card in a collection, an empty grid
/// cell, an "add" affordance. Distinct from a full-screen empty state; this is
/// an inline slot inside a grid or row.
class EmptyCard extends StatelessWidget {
  const EmptyCard({
    required this.label,
    this.icon,
    this.onTap,
    this.height = 120,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textDisabled;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgAll,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: color, radius: AppRadius.lg),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: color),
                const SizedBox(height: AppSpacing.sm),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: context.textTheme.labelMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
