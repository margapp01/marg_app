import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/yatra_route.dart';

/// The completion medal — the shared [GoldSeal] at showcase size.
class CompletionMedal extends StatelessWidget {
  const CompletionMedal({this.size = 128, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => GoldSeal(icon: AppIcons.route, size: size, glow: true);
}

/// A premium, printable-style completion certificate rendered from real data:
/// parchment in the collectibles' gilt frame. The PDF comes from the backend.
class CertificateCard extends StatelessWidget {
  const CertificateCard({
    required this.routeName,
    required this.userName,
    this.completedOn,
    super.key,
  });

  final String routeName;
  final String userName;
  final DateTime? completedOn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary);
    final date = completedOn;
    return GiltFrame(
      accent: context.colors.gold,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.parchment),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
          child: Column(
            children: [
              Text(
                l10n.ryCertificateTitle.toUpperCase(),
                textAlign: TextAlign.center,
                style: context.overline.copyWith(color: context.colors.gold, letterSpacing: 1.6),
              ),
              const Gap(AppSpacing.md),
              Text(l10n.ryCertifyThat, style: muted, textAlign: TextAlign.center),
              const Gap(AppSpacing.xs),
              Text(userName, style: context.brandText.headlineSmall, textAlign: TextAlign.center),
              const Gap(AppSpacing.xs),
              Text(l10n.ryHasCompleted, style: muted, textAlign: TextAlign.center),
              const Gap(AppSpacing.xs),
              Text(
                routeName,
                style: context.displayText.titleLarge.withColor(context.scheme.primary),
                textAlign: TextAlign.center,
              ),
              const Gap(AppSpacing.md),
              Text(l10n.ryBlessings, style: muted?.copyWith(fontStyle: FontStyle.italic), textAlign: TextAlign.center),
              const Gap(AppSpacing.lg),
              const GoldSeal(),
              const Gap(AppSpacing.lg),
              const GoldRule(),
              const Gap(AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (date != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(date),
                          style: context.textTheme.bodySmall?.semiBold,
                        ),
                        Text(l10n.ryCertDate, style: context.caption.copyWith(color: context.colors.textSecondary)),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const BrandLogo(size: 18),
                      Text(l10n.ryCertIssuer, style: context.caption.copyWith(color: context.colors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The route's reward card in the gilt frame, glowing in its rarity colour.
class RewardCardArt extends StatelessWidget {
  const RewardCardArt({required this.card, super.key});

  final RouteRewardCard card;

  static const double _maxWidth = 200;

  @override
  Widget build(BuildContext context) {
    final accent = rarityColor(context, card.rarity);
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: GiltFrame(
            accent: accent,
            large: true,
            aspectRatio: 3 / 4,
            child: card.imageUrl.isEmpty
                ? ColoredBox(color: accent.withValues(alpha: 0.15))
                : AppNetworkImage(url: card.imageUrl, fit: BoxFit.cover),
          ),
        ),
        const Gap(AppSpacing.md),
        Text(card.title, style: context.textTheme.titleSmall?.semiBold, textAlign: TextAlign.center),
        Text(rarityLabel(AppLocalizations.of(context), card.rarity), style: context.caption.copyWith(color: accent)),
      ],
    );
  }
}
