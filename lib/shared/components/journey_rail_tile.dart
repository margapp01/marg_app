import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import 'app_card.dart';
import 'app_network_image.dart';

/// One stop on a journey rail — a coloured node (an icon, or a [nodeLabel]
/// such as a stop number) on a vertical line, then a card with an optional
/// photo, title, subtitle and a small [caption] line (a date, a status).
/// Passport's Journey Timeline and a yatra's timeline are built from it.
class JourneyRailTile extends StatelessWidget {
  const JourneyRailTile({
    required this.icon,
    required this.color,
    required this.title,
    this.nodeLabel,
    this.subtitle,
    this.caption,
    this.captionIcon,
    this.captionColor,
    this.imageUrl,
    this.trailing,
    this.isLast = false,
    this.highlighted = false,
    this.muted = false,
    this.onTap,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 1,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;

  /// Shown in the node instead of [icon] (e.g. "5").
  final String? nodeLabel;
  final String? subtitle;
  final String? caption;
  final IconData? captionIcon;
  final Color? captionColor;
  final String? imageUrl;
  final Widget? trailing;

  /// The rail stops at this node.
  final bool isLast;

  /// Outlined card in the accent colour — e.g. the next stop.
  final bool highlighted;

  /// A stop not reached yet: hollow node, softer card.
  final bool muted;
  final VoidCallback? onTap;

  /// Lines the title / subtitle may wrap to (e.g. a feed message).
  final int titleMaxLines;
  final int subtitleMaxLines;

  static const double _node = 36;
  static const double _thumb = 52;

  @override
  Widget build(BuildContext context) {
    final railColor = muted ? context.colors.border : color.withValues(alpha: 0.45);
    final capColor = captionColor ?? context.colors.textDisabled;
    final label = nodeLabel;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _node,
            child: Column(
              children: [
                Container(
                  width: _node,
                  height: _node,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: muted ? context.colors.card : Color.alphaBlend(color.withValues(alpha: 0.14), context.colors.card),
                    border: Border.all(color: muted ? context.colors.border : color.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: label != null
                      ? Text(label, style: context.textTheme.labelMedium?.bold.withColor(muted ? context.colors.textSecondary : color))
                      : Icon(icon, size: 18, color: muted ? context.colors.textDisabled : color, fill: 1),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [railColor, context.colors.border],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                onTap: onTap,
                selected: highlighted,
                padding: AppSpacing.allSm,
                child: Opacity(
                  opacity: muted ? 0.8 : 1,
                  child: Row(
                    children: [
                      if (imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: AppRadius.mdAll,
                          child: SizedBox.square(
                            dimension: _thumb,
                            child: AppNetworkImage(url: imageUrl!, fit: BoxFit.cover),
                          ),
                        ),
                        const Gap.h(AppSpacing.md),
                      ] else
                        const Gap.h(AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: titleMaxLines,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary),
                            ),
                            if (subtitle != null && subtitle!.isNotEmpty)
                              Text(
                                subtitle!,
                                maxLines: subtitleMaxLines,
                                overflow: TextOverflow.ellipsis,
                                style: context.caption.copyWith(color: context.colors.textSecondary),
                              ),
                            if (caption != null) ...[
                              const Gap(AppSpacing.xxs),
                              Row(
                                children: [
                                  if (captionIcon != null) ...[
                                    Icon(captionIcon, size: 13, color: capColor),
                                    const Gap.h(AppSpacing.xxs),
                                  ],
                                  Flexible(
                                    child: Text(
                                      caption!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.caption.copyWith(color: capColor),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (trailing != null) ...[const Gap.h(AppSpacing.xs), trailing!],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
