import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../badges/app_badge.dart';
import '../images/illustrated_icon.dart';
import 'parchment_card.dart';

/// The parchment intro at the top of a settings / account screen: an
/// illustrated icon, a serif title, one line on what the screen holds and an
/// optional [status] pill (e.g. "8 of 11 on").
class IntroBanner extends StatelessWidget {
  const IntroBanner({
    required this.icon,
    required this.title,
    required this.message,
    this.color,
    this.status,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Icon tint (defaults to saffron).
  final Color? color;
  final String? status;

  static const double _iconSize = 52;

  @override
  Widget build(BuildContext context) {
    return ParchmentCard(
      child: Row(
        children: [
          IllustratedIcon(fallbackIcon: icon, color: color ?? context.scheme.primary, size: _iconSize),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.displayText.titleLarge.withColor(context.scheme.secondary)),
                const Gap(AppSpacing.xxs),
                Text(message, style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary)),
                if (status != null) ...[
                  const Gap(AppSpacing.sm),
                  AppBadge(label: status!, tone: AppBadgeTone.primary),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
