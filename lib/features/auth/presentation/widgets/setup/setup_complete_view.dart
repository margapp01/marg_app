import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../shared/design_system.dart';

/// Shown once setup is saved: "You're all set!" over the temple-arch art, a
/// glimpse of what the devotee can do next, and the way into the app.
class SetupCompleteView extends StatelessWidget {
  const SetupCompleteView({required this.onStart, super.key});

  final VoidCallback onStart;

  static const String _brand = 'MARG';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final body = l10n.suCompleteBody(_brand);
    final brandAt = body.indexOf(_brand);
    final bodyStyle = context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, height: 1.5);
    final next = [
      _NextStep(BrandAssets.iconNearby, AppIcons.temple, p.accentSaffron, l10n.suNextExploreTitle, l10n.suNextExploreSubtitle),
      _NextStep(BrandAssets.iconRoutes, AppIcons.route, p.accentBlue, l10n.suNextRoutesTitle, l10n.suNextRoutesSubtitle),
      _NextStep(BrandAssets.iconCards, AppIcons.card, p.accentViolet, l10n.suNextCardsTitle, l10n.suNextCardsSubtitle),
      _NextStep(BrandAssets.iconAchievements, AppIcons.achievement, p.accentAmber, l10n.suNextAchievementsTitle, l10n.suNextAchievementsSubtitle),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.screenAll,
            children: [
              const Gap(AppSpacing.lg),
              Semantics(
                header: true,
                child: Text(l10n.suAllSet, textAlign: TextAlign.center, style: context.displayText.headlineMedium),
              ).fadeIn(),
              const Gap(AppSpacing.sm),
              Text.rich(
                TextSpan(
                  children: brandAt < 0
                      ? [TextSpan(text: body)]
                      : [
                          TextSpan(text: body.substring(0, brandAt)),
                          TextSpan(
                            text: _brand,
                            style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.primary),
                          ),
                          TextSpan(text: body.substring(brandAt + _brand.length)),
                        ],
                ),
                textAlign: TextAlign.center,
                style: bodyStyle,
              ).fadeIn(delay: 80.ms),
              const Gap(AppSpacing.lg),
              ExcludeSemantics(
                child: Image.asset(
                  BrandAssets.illustrationSetupComplete,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ).scaleIn(delay: 160.ms),
              const Gap(AppSpacing.xl),
              Text(
                l10n.suWhatsNext,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.secondary),
              ),
              const Gap(AppSpacing.xxs),
              Text(l10n.suWhatsNextSubtitle, textAlign: TextAlign.center, style: bodyStyle),
              const Gap(AppSpacing.md),
              for (var row = 0; row < next.length; row += 2) ...[
                if (row > 0) const Gap(AppSpacing.sm),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _NextTile(step: next[row])),
                      const Gap.h(AppSpacing.sm),
                      Expanded(child: _NextTile(step: next[row + 1])),
                    ],
                  ),
                ).slideIn(delay: (240 + row * 40).ms),
              ],
            ],
          ),
        ),
        Padding(
          padding: AppSpacing.screenAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(label: l10n.suStartJourney, trailingIcon: AppIcons.arrowForward, onPressed: onStart),
              const Gap(AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.lock, size: 14, color: context.colors.textSecondary),
                  const Gap.h(AppSpacing.xs),
                  Text(l10n.suDataSecure, style: context.caption.copyWith(color: context.colors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One "What's next?" suggestion.
class _NextStep {
  const _NextStep(this.asset, this.icon, this.color, this.title, this.subtitle);

  final String asset;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}

class _NextTile extends StatelessWidget {
  const _NextTile({required this.step});

  final _NextStep step;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IllustratedIcon(asset: step.asset, fallbackIcon: step.icon, color: step.color, size: 40),
          const Gap(AppSpacing.sm),
          Text(step.title, style: context.textTheme.labelLarge?.semiBold),
          const Gap(AppSpacing.xxs),
          Text(step.subtitle, style: context.caption.copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }
}
