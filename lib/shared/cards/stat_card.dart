import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../animations/animated_count.dart';
import '../components/app_card.dart';
import '../images/illustrated_icon.dart';

/// A compact metric tile: an illustrated icon, a large animated value in the
/// display face and a label — visits, cards, trust score. Designed to sit in a
/// grid/row of stats.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    this.icon,
    this.accent,
    this.suffix = '',
    this.onTap,
    this.animate = true,
    super.key,
  });

  final String label;

  /// Numeric value; animated on change when [animate] is true.
  final int value;
  final IconData? icon;

  /// Icon tint (defaults to saffron).
  final Color? accent;
  final String suffix;
  final VoidCallback? onTap;
  final bool animate;

  static const double _iconSize = 40;

  @override
  Widget build(BuildContext context) {
    final valueStyle = context.displayText.headlineSmall.withColor(context.scheme.secondary);
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IllustratedIcon(fallbackIcon: icon!, color: accent ?? context.scheme.primary, size: _iconSize),
            const SizedBox(height: AppSpacing.sm),
          ],
          animate
              ? AnimatedCount(value: value, suffix: suffix, style: valueStyle)
              : Text('$value$suffix', style: valueStyle),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
