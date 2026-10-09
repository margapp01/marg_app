import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';

/// A tinted entry tile in one [accent]: a soft accent wash with a matching
/// hairline, a round icon badge, the title in the display face, an optional
/// accent subtitle and a faint [icon] watermark in the corner — states on
/// Explore, journey sections on the Passport.
///
/// Fills the size its parent gives it (a fixed rail slot or a grid cell).
class AccentTile extends StatelessWidget {
  const AccentTile({
    required this.icon,
    required this.title,
    required this.accent,
    this.subtitle,
    this.watermark,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final String? subtitle;

  /// Corner watermark (defaults to [icon]).
  final IconData? watermark;
  final VoidCallback? onTap;
  final String? semanticLabel;

  static const double _badge = 34;
  static const double _watermark = 72;

  @override
  Widget build(BuildContext context) {
    final card = context.colors.card;
    return Semantics(
      button: onTap != null,
      label: semanticLabel ?? [title, subtitle].whereType<String>().join(', '),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.card,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: AppRadius.card,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.alphaBlend(accent.withValues(alpha: 0.16), card), card],
              ),
              border: Border.all(color: accent.withValues(alpha: 0.28)),
              boxShadow: AppShadows.xs,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.card,
              child: Stack(
                children: [
                  Positioned(
                    right: -AppSpacing.sm,
                    bottom: -AppSpacing.sm,
                    child: Icon(watermark ?? icon, size: _watermark, color: accent.withValues(alpha: 0.1), fill: 1),
                  ),
                  Padding(
                    padding: AppSpacing.allMd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: _badge,
                          height: _badge,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.16)),
                          child: Icon(icon, size: _badge * 0.55, color: accent, fill: 1),
                        ),
                        const Gap(AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.displayText.titleLarge.withColor(context.scheme.secondary),
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.caption.semiBold.copyWith(color: accent),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
