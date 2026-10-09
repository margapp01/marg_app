import 'package:flutter/material.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../animations/app_progress.dart';
import '../components/app_network_image.dart';
import '../images/branded_fallback.dart';
import 'temple_card_base.dart';

/// (label, icon) for a backend `RouteType`.
({String label, IconData icon}) routeTypeMeta(AppLocalizations l10n, String type) {
  switch (type.toUpperCase()) {
    case 'JYOTIRLINGA':
      return (label: l10n.ryTypeJyotirlinga, icon: AppIcons.temple);
    case 'SHAKTI_PEETH':
      return (label: l10n.ryTypeShaktiPeeth, icon: AppIcons.aarti);
    case 'CHAR_DHAM':
      return (label: l10n.ryTypeCharDham, icon: AppIcons.route);
    default:
      return (label: l10n.ryTypeCustom, icon: AppIcons.star);
  }
}

/// The one route card — a full-bleed cover with a dark scrim, the route-type
/// badge and serif name. With a [percent] it shows temples done and a saffron
/// progress bar (My Yatras, Passport Routes); without one, the description and
/// temple count (Discover).
///
/// [pill] replaces the type label top-left (e.g. "Completed"); [footnote] adds
/// one line under the progress (the next temple, or the completion date).
class RouteCard extends StatelessWidget {
  const RouteCard({
    required this.name,
    required this.type,
    required this.templeCount,
    this.coverImage,
    this.description,
    this.percent,
    this.completedTemples,
    this.pill,
    this.footnote,
    this.footnoteIcon,
    this.onTap,
    super.key,
  });

  final String name;
  final String type;
  final int templeCount;
  final String? coverImage;
  final String? description;
  final int? percent;
  final int? completedTemples;
  final PhotoPill? pill;
  final String? footnote;
  final IconData? footnoteIcon;
  final VoidCallback? onTap;

  static const double _discoverHeight = 196;
  static const double _progressHeight = 176;
  static const double _footnoteHeight = 22;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meta = routeTypeMeta(l10n, type);
    const white = Colors.white;
    final dim = white.withValues(alpha: 0.75);
    final topLeft = pill ?? (percent == null ? PhotoPill(label: meta.label) : null);
    final height = percent == null ? _discoverHeight : _progressHeight + (footnote == null ? 0 : _footnoteHeight);
    return Semantics(
      button: true,
      label: percent == null ? name : '$name, $percent%',
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: SizedBox(
          height: height,
          child: Material(
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverImage == null)
                    const BrandedImageFallback()
                  else
                    AppNetworkImage(url: coverImage!, fallback: const BrandedImageFallback()),
                  const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.photoScrim)),
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: AppSpacing.allSm,
                      decoration: BoxDecoration(color: context.colors.card.withValues(alpha: 0.9), shape: BoxShape.circle),
                      child: Icon(meta.icon, size: 20, color: context.palette.accentSaffron, fill: 1),
                    ),
                  ),
                  if (topLeft != null) Positioned(top: AppSpacing.md, left: AppSpacing.md, child: topLeft),
                  Positioned(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.displayText.titleLarge.copyWith(color: white),
                        ),
                        if (percent != null) ...[
                          Text(
                            '${completedTemples ?? 0} / $templeCount ${l10n.ryTemplesCompleted}',
                            style: context.textTheme.bodySmall?.copyWith(color: dim),
                          ),
                          const Gap(AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: AppLinearProgress(
                                  value: (percent! / 100).clamp(0, 1),
                                  height: 6,
                                  color: percent! >= 100 ? context.colors.gold : context.palette.accentSaffron,
                                  backgroundColor: white.withValues(alpha: 0.24),
                                ),
                              ),
                              const Gap.h(AppSpacing.sm),
                              Text('$percent%', style: context.textTheme.labelLarge?.bold.withColor(white)),
                            ],
                          ),
                          if (footnote != null) ...[
                            const Gap(AppSpacing.xs),
                            Row(
                              children: [
                                Icon(footnoteIcon ?? AppIcons.info, size: 14, color: context.colors.gold),
                                const Gap.h(AppSpacing.xxs),
                                Expanded(
                                  child: Text(
                                    footnote!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.caption.copyWith(color: dim),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ] else ...[
                          if (description != null && description!.isNotEmpty)
                            Text(
                              description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodySmall?.copyWith(color: dim),
                            ),
                          const Gap(AppSpacing.sm),
                          Row(
                            children: [
                              Icon(AppIcons.temple, size: 16, color: context.colors.gold),
                              const Gap.h(AppSpacing.xxs),
                              Text(
                                '$templeCount ${l10n.ryTemples}',
                                style: context.textTheme.labelMedium?.semiBold.withColor(white),
                              ),
                              const Spacer(),
                              const Icon(AppIcons.arrowForward, size: 20, color: white),
                            ],
                          ),
                        ],
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
