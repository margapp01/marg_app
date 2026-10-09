import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// Semantic colour of a badge. Resolved against the theme so badges read
/// consistently and adapt with a future dark scheme.
enum AppBadgeTone { neutral, primary, success, warning, error, info, gold, silver, bronze }

/// The base pill badge — a small label with an optional leading icon, in a
/// semantic [tone]. Every badge (status, verification, trust, points, tier)
/// builds on this. Prefer a semantic preset where one exists.
class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.icon,
    this.solid = false,
    super.key,
  });

  final String label;
  final AppBadgeTone tone;
  final IconData? icon;

  /// Solid fill (tone colour + white text) vs. soft (tinted bg + tone text).
  final bool solid;

  Color _color(BuildContext context) => switch (tone) {
        AppBadgeTone.neutral => context.colors.textSecondary,
        AppBadgeTone.primary => context.scheme.primary,
        AppBadgeTone.success => context.colors.success,
        AppBadgeTone.warning => context.colors.warning,
        AppBadgeTone.error => context.scheme.error,
        AppBadgeTone.info => context.colors.info,
        AppBadgeTone.gold => context.colors.gold,
        AppBadgeTone.silver => context.colors.silver,
        AppBadgeTone.bronze => context.colors.bronze,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    final fg = solid ? AppColors.onPrimary : color;
    final bg = solid ? color : color.withValues(alpha: 0.14);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.fullAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: context.textTheme.labelSmall
                ?.copyWith(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
