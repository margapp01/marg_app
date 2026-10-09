import 'package:flutter/material.dart';

import '../../app/constants/brand_assets.dart';
import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../animations/animate_x.dart';
import '../images/gold_ring_avatar.dart';

/// The pilgrim's identity: avatar in a glowing gold ring over a faint temple
/// skyline, name in the display face (with a verified tick) and a gold-rimmed
/// level ribbon. The hero of the Passport and Profile tabs.
class PilgrimHero extends StatelessWidget {
  const PilgrimHero({required this.name, this.imageUrl, this.level, this.verified = false, super.key});

  final String name;
  final String? imageUrl;

  /// e.g. "Level · Devotee"; hidden while unknown.
  final String? level;
  final bool verified;

  static const double _skylineHeight = 96;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: GoldRingAvatar.diameterFor(GoldRingAvatar.defaultRadius) * 0.3,
          height: _skylineHeight,
          child: ExcludeSemantics(
            child: Image.asset(
              BrandAssets.skylineLineArt,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              opacity: const AlwaysStoppedAnimation(0.22),
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
        Column(
          children: [
            GoldRingAvatar(imageUrl: imageUrl, name: name).scaleIn(),
            const Gap(AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: context.displayText.headlineMedium.withColor(context.scheme.secondary),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (verified) ...[
                  const Gap.h(AppSpacing.xs),
                  Icon(AppIcons.verified, size: 22, color: context.palette.accentBlue, fill: 1),
                ],
              ],
            ),
            if (level != null) ...[
              const Gap(AppSpacing.xs),
              _LevelRibbon(text: level!),
            ],
          ],
        ),
      ],
    );
  }
}

/// "Level · Devotee" on a navy pill with a gold rim and a gold star.
class _LevelRibbon extends StatelessWidget {
  const _LevelRibbon({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final gold = context.colors.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs + 1),
      decoration: BoxDecoration(
        gradient: AppGradients.navy,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: gold, width: 1.2),
        boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.3), blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.star, size: 14, color: gold, fill: 1),
          const Gap.h(AppSpacing.xs),
          Flexible(
            child: Text(
              text,
              style: context.textTheme.labelMedium?.semiBold.withColor(gold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
