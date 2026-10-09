import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/explore_models.dart';

/// Localized label for a temple `DeityType` wire value.
String deityLabel(AppLocalizations l10n, String? wire) {
  switch (wire?.toUpperCase()) {
    case 'SHIVA':
      return l10n.exDeityShiva;
    case 'VISHNU':
      return l10n.exDeityVishnu;
    case 'DEVI':
      return l10n.exDeityDevi;
    case 'HANUMAN':
      return l10n.exDeityHanuman;
    case 'GANESHA':
      return l10n.exDeityGanesha;
    default:
      return l10n.exDeityOther;
  }
}

/// Cycles the palette's accents so neighbouring tiles (e.g. states) differ.
Color stateAccent(BuildContext context, int i) {
  final p = context.palette;
  final accents = [p.accentSaffron, p.accentViolet, p.accentBlue, p.accentGreen, p.accentRose, p.accentAmber, p.accentTeal];
  return accents[i % accents.length];
}

/// The temple thumbnail: the cover photo (else the Sacred Card art), falling
/// back to a deity-tinted placeholder when there's no image or it fails.
class TempleThumb extends StatelessWidget {
  const TempleThumb({required this.temple, this.width, this.height, super.key});

  final ExploreTemple temple;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final accent = deityColor(context, temple.deity);
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.22), accent.withValues(alpha: 0.08)],
        ),
      ),
      child: Icon(AppIcons.temple, color: accent, size: 30),
    );
    final url = temple.imageUrl;
    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: url == null ? placeholder : AppNetworkImage(url: url, width: width, height: height, fallback: placeholder),
    );
  }
}

/// The flagship reusable temple card. [compact] renders a photo tile for
/// horizontal rails; otherwise a full-width photo row with actions.
class ExploreTempleCard extends StatelessWidget {
  const ExploreTempleCard({
    required this.temple,
    required this.onTap,
    this.onNavigate,
    this.compact = false,
    super.key,
  });

  final ExploreTemple temple;
  final VoidCallback onTap;
  final VoidCallback? onNavigate;
  final bool compact;

  /// Height a horizontal rail needs for [compact] cards.
  static const double railHeight = 248;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = OpenStatusLabel(
      isOpen: temple.openStatus.isOpen,
      opensAt: temple.openStatus.opensAt,
      closesAt: temple.openStatus.closesAt,
    );
    if (compact) {
      return SizedBox(
        width: 168,
        child: TempleCardBase(
          dense: true,
          imageHeight: 112,
          name: temple.name,
          location: temple.location,
          imageUrl: temple.imageUrl,
          chip: temple.formattedDistance == null
              ? null
              : PhotoPill(label: temple.formattedDistance!, icon: AppIcons.nearby),
          trailing: temple.isVerified
              ? Icon(AppIcons.verified, size: 16, color: context.colors.success, fill: 1)
              : null,
          footer: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingBadge(rating: temple.ratingAverage, count: temple.ratingCount),
              status,
            ],
          ),
          onTap: onTap,
        ),
      );
    }
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TempleThumb(temple: temple, width: 96, height: 96),
              const Gap.h(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            temple.name,
                            style: context.textTheme.titleSmall?.semiBold,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (temple.formattedDistance != null)
                          Text(
                            temple.formattedDistance!,
                            style: context.textTheme.labelMedium?.semiBold.withColor(context.palette.accentBlue),
                          ),
                      ],
                    ),
                    if (temple.location.isNotEmpty)
                      Text(
                        temple.location,
                        style: context.caption.copyWith(color: context.colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Gap(AppSpacing.xs),
                    RatingBadge(rating: temple.ratingAverage, count: temple.ratingCount),
                    status,
                    const Gap(AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        _pill(context, AppIcons.temple, deityLabel(l10n, temple.deity)),
                        if (temple.isVerified) _pill(context, AppIcons.verified, l10n.tdVerified),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          Row(
            children: [
              if (onNavigate != null) ...[
                Expanded(
                  child: AppButton.outlined(
                    label: l10n.exNavigate,
                    icon: AppIcons.directions,
                    size: AppButtonSize.small,
                    onPressed: onNavigate,
                  ),
                ),
                const Gap.h(AppSpacing.sm),
              ],
              Expanded(
                child: AppButton.primary(label: l10n.exViewTemple, size: AppButtonSize.small, onPressed: onTap),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
    decoration: BoxDecoration(color: context.palette.tilePeach, borderRadius: AppRadius.fullAll),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: context.palette.accentSaffron),
        const Gap.h(AppSpacing.xxs),
        Text(text, style: context.textTheme.labelSmall?.withColor(context.palette.accentSaffron)),
      ],
    ),
  );
}

/// A deity category as a photo card: its most-viewed temple behind a scrim,
/// the deity's illustrated emblem, its name in the display face and the
/// temple count. [featured] is the tall full-width card that leads the page.
class CategoryCard extends StatelessWidget {
  const CategoryCard({required this.category, required this.onTap, this.featured = false, super.key});

  final TempleCategory category;
  final VoidCallback onTap;
  final bool featured;

  static const double featuredHeight = ExploreCoverCard.featuredHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = deityColor(context, category.deity.wire);
    final top = category.topTemple;
    return ExploreCoverCard(
      title: deityLabel(l10n, category.deity.wire),
      countLabel: l10n.exStateTemples(category.count),
      caption: featured && top != null ? l10n.exMostVisited(top) : null,
      coverImage: category.coverImage,
      accent: accent,
      emblem: IllustratedIcon(
        asset: deityAsset(category.deity.wire),
        fallbackIcon: AppIcons.temple,
        color: accent,
        background: context.colors.card.withValues(alpha: 0.92),
        size: featured ? ExploreCoverCard.featuredEmblemSize : ExploreCoverCard.emblemSize,
      ),
      featured: featured,
      onTap: onTap,
    );
  }
}

/// The Explore photo card — a cover photo (a category's, state's or
/// collection's lead temple) behind a dark scrim, a count pill, an emblem,
/// the title in the display face and an optional [caption]. Fills its parent;
/// [featured] is the bold full-width version that leads a page.
class ExploreCoverCard extends StatelessWidget {
  const ExploreCoverCard({
    required this.title,
    required this.countLabel,
    required this.accent,
    required this.emblem,
    required this.onTap,
    this.coverImage,
    this.caption,
    this.featured = false,
    super.key,
  });

  final String title;
  final String countLabel;
  final Color accent;
  final Widget emblem;
  final VoidCallback onTap;
  final String? coverImage;
  final String? caption;
  final bool featured;

  static const double featuredHeight = 196;
  static const double emblemSize = 44;
  static const double featuredEmblemSize = 56;

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    final cover = coverImage;
    final caption = this.caption;
    return Semantics(
      button: true,
      label: '$title, $countLabel',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (cover == null)
                  const BrandedImageFallback()
                else
                  AppNetworkImage(url: cover, fit: BoxFit.cover, fallback: const BrandedImageFallback()),
                const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.photoScrim)),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: PhotoPill(label: countLabel, icon: AppIcons.temple, color: accent),
                ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      emblem,
                      const Gap.h(AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: (featured ? context.displayText.headlineSmall : context.displayText.titleLarge)
                                  .copyWith(color: white),
                            ),
                            if (caption != null)
                              Text(
                                caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.caption.copyWith(color: white.withValues(alpha: 0.8)),
                              ),
                          ],
                        ),
                      ),
                      if (featured) const Icon(AppIcons.arrowForward, color: white),
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

/// A round illustrated mark for a cover card's [ExploreCoverCard.emblem].
class CoverEmblem extends StatelessWidget {
  const CoverEmblem({required this.icon, required this.color, this.featured = false, super.key});

  final IconData icon;
  final Color color;
  final bool featured;

  @override
  Widget build(BuildContext context) => IllustratedIcon(
    fallbackIcon: icon,
    color: color,
    background: context.colors.card.withValues(alpha: 0.92),
    size: featured ? ExploreCoverCard.featuredEmblemSize : ExploreCoverCard.emblemSize,
  );
}
