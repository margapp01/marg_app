import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/route_detail_bundle.dart';
import '../../domain/entities/yatra_route.dart';

/// A small type badge (chip) for a route.
class RouteTypeChip extends StatelessWidget {
  const RouteTypeChip({required this.type, super.key});

  final String type;

  @override
  Widget build(BuildContext context) {
    final meta = routeTypeMeta(AppLocalizations.of(context), type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: context.scheme.primary.withValues(alpha: 0.1),
        borderRadius: AppRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 13, color: context.scheme.primary),
          const Gap(AppSpacing.xxs),
          Text(meta.label, style: context.overline.copyWith(color: context.scheme.primary)),
        ],
      ),
    );
  }
}

/// A compact row for planned (not yet started) yatras with a "Start" link.
class PlannedRouteTile extends StatelessWidget {
  const PlannedRouteTile({
    required this.name,
    required this.templeCount,
    required this.onTap,
    this.coverImage,
    super.key,
  });

  final String name;
  final int templeCount;
  final String? coverImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      gradient: AppGradients.peach,
      variant: AppCardVariant.filled,
      onTap: onTap,
      padding: AppSpacing.allMd,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: SizedBox.square(
              dimension: 64,
              child: coverImage == null
                  ? const BrandedImageFallback(iconSize: 32)
                  : AppNetworkImage(url: coverImage!, fallback: const BrandedImageFallback(iconSize: 32)),
            ),
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.titleSmall?.semiBold),
                Text('0 / $templeCount ${l10n.ryTemplesCompleted}', style: context.caption.copyWith(color: context.colors.textSecondary)),
                const Gap(AppSpacing.xs),
                Text(l10n.ryStartJourney, style: context.textTheme.labelMedium?.bold.withColor(context.palette.accentSaffron)),
              ],
            ),
          ),
          Icon(AppIcons.chevronRight, color: context.colors.textSecondary),
        ],
      ),
    );
  }
}

/// One temple in the route checklist: stop number, photo, name, place, the
/// visit date, and a status badge. The next stop is outlined.
class TempleChecklistItem extends StatelessWidget {
  const TempleChecklistItem({
    required this.index,
    required this.entry,
    required this.status,
    this.visitedOn,
    this.onTap,
    super.key,
  });

  final int index;
  final RouteTempleEntry entry;
  final TempleJourneyStatus status;
  final String? visitedOn;
  final VoidCallback? onTap;

  static const double _number = 28;
  static const double _thumb = 52;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final temple = entry.temple;
    final (accent, badge) = switch (status) {
      TempleJourneyStatus.completed => (
          context.colors.success,
          AppBadge(label: l10n.ryVisited, icon: AppIcons.check, tone: AppBadgeTone.success),
        ),
      TempleJourneyStatus.current => (
          context.scheme.primary,
          AppBadge(label: l10n.ryNextBadge, icon: AppIcons.navigation, tone: AppBadgeTone.primary),
        ),
      TempleJourneyStatus.remaining => (
          context.colors.textSecondary,
          AppBadge(label: l10n.ryStatusUpcoming, tone: AppBadgeTone.neutral),
        ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        selected: status == TempleJourneyStatus.current,
        padding: AppSpacing.allSm,
        child: Row(
          children: [
            Container(
              width: _number,
              height: _number,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.14)),
              child: Text('$index', style: context.textTheme.labelMedium?.bold.withColor(accent)),
            ),
            const Gap.h(AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.mdAll,
              child: SizedBox.square(
                dimension: _thumb,
                child: temple.imageUrl == null
                    ? const BrandedImageFallback(iconSize: 24)
                    : AppNetworkImage(url: temple.imageUrl!, fallback: const BrandedImageFallback(iconSize: 24)),
              ),
            ),
            const Gap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    temple.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary),
                  ),
                  if (temple.location != null)
                    Text(
                      temple.location!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.caption.copyWith(color: context.colors.textSecondary),
                    ),
                  if (visitedOn != null)
                    Text(visitedOn!, style: context.caption.copyWith(color: context.colors.success)),
                ],
              ),
            ),
            const Gap.h(AppSpacing.xs),
            badge,
          ],
        ),
      ),
    );
  }
}
