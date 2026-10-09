import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../components/app_network_image.dart';

/// Presentational temple card: photo on top (with optional overlay [chip]
/// top-left and [badge] top-right), then name, location and a [footer] slot
/// (rating, open status, CTA). Feature code maps a temple onto this — the
/// design system owns the look, not the data.
///
/// [dense] is the compact rail variant used in horizontal lists.
///
/// In a fixed-height slot (a rail or a fixed-extent grid cell) the photo
/// grows to absorb any spare height, so a card whose text runs short (e.g.
/// no ratings yet) never shows a blank band; [imageHeight] applies only when
/// the height is unbounded.
class TempleCardBase extends StatelessWidget {
  const TempleCardBase({
    required this.name,
    required this.location,
    this.imageUrl,
    this.chip,
    this.badge,
    this.trailing,
    this.footer,
    this.onTap,
    this.imageHeight = 140,
    this.dense = false,
    super.key,
  });

  final String name;
  final String location;
  final String? imageUrl;

  /// e.g. a distance pill overlaid top-left on the image.
  final Widget? chip;

  /// e.g. a save/heart button overlaid top-right on the image.
  final Widget? badge;

  /// e.g. a verification badge, shown beside the name.
  final Widget? trailing;

  /// e.g. rating + open status, below the location.
  final Widget? footer;
  final VoidCallback? onTap;
  final double imageHeight;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final pad = dense ? AppSpacing.allMd : AppSpacing.allLg;
    final sand = ColoredBox(
      color: context.colors.templeSand,
      child: Center(
        child: Icon(AppIcons.temple, color: context.colors.templeStone, size: imageHeight * 0.3),
      ),
    );
    final photo = Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl == null) sand else AppNetworkImage(url: imageUrl!, fallback: sand),
        if (chip != null) Positioned(top: AppSpacing.sm, left: AppSpacing.sm, child: chip!),
        if (badge != null) Positioned(top: AppSpacing.xs, right: AppSpacing.xs, child: badge!),
      ],
    );
    return DecoratedBox(
      decoration: const BoxDecoration(borderRadius: AppRadius.lgAll, boxShadow: AppShadows.sm),
      child: Material(
        color: context.colors.card,
        borderRadius: AppRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (constraints.hasBoundedHeight)
                  Expanded(
                    child: SizedBox(width: double.infinity, child: photo),
                  )
                else
                  SizedBox(height: imageHeight, width: double.infinity, child: photo),
                Padding(
                  padding: pad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: (dense ? context.textTheme.titleSmall : context.textTheme.titleMedium)?.semiBold,
                              maxLines: dense ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (trailing != null) ...[const Gap.h(AppSpacing.sm), trailing!],
                        ],
                      ),
                      if (location.isNotEmpty) ...[
                        const Gap(AppSpacing.xxs),
                        Row(
                          children: [
                            Icon(AppIcons.location, size: 14, color: context.colors.textSecondary),
                            const Gap.h(AppSpacing.xxs),
                            Expanded(
                              child: Text(
                                location,
                                style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (footer != null) ...[const Gap(AppSpacing.sm), footer!],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small frosted pill for overlaying on photos ("📍 0.8 km").
class PhotoPill extends StatelessWidget {
  const PhotoPill({required this.label, this.icon, this.color, super.key});

  final String label;
  final IconData? icon;

  /// Icon tint (defaults to blue).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs + 1),
      decoration: BoxDecoration(
        color: context.colors.card.withValues(alpha: 0.92),
        borderRadius: AppRadius.fullAll,
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color ?? context.palette.accentBlue, fill: 1),
            const Gap.h(AppSpacing.xxs),
          ],
          Text(label, style: context.textTheme.labelSmall?.semiBold.withColor(context.scheme.onSurface)),
        ],
      ),
    );
  }
}
