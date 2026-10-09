import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/utils/formatters.dart';

/// "★ 4.8 (12.5K)" — a temple's average rating with its review count.
/// Hidden when there are no reviews yet (never shows a misleading 0.0).
class RatingBadge extends StatelessWidget {
  const RatingBadge({
    required this.rating,
    required this.count,
    this.onDark = false,
    super.key,
  });

  final double rating;
  final int count;

  /// Use light text over photos / dark surfaces.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final textColor = onDark ? Colors.white : context.scheme.onSurface;
    final muted = onDark ? Colors.white70 : context.colors.textSecondary;
    return Semantics(
      label: '${rating.toStringAsFixed(1)} stars, $count reviews',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.star, size: 14, color: context.palette.accentAmber, fill: 1),
          const Gap.h(AppSpacing.xxs),
          Text(
            rating.toStringAsFixed(1),
            style: context.textTheme.labelMedium?.copyWith(color: textColor, fontWeight: AppTypography.semiBold),
          ),
          const Gap.h(AppSpacing.xxs),
          Text('(${compactCount(count)})', style: context.textTheme.labelSmall?.copyWith(color: muted)),
        ],
      ),
    );
  }
}
