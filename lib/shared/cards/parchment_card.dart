import 'package:flutter/material.dart';

import '../../app/constants/brand_assets.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// A warm parchment panel with a gold hairline and the saffron temple skyline
/// tucked into its bottom-right corner — the hero surface of collection hubs
/// (Sacred Cards, Achievements).
class ParchmentCard extends StatelessWidget {
  const ParchmentCard({required this.child, this.padding = AppSpacing.allLg, super.key});

  final Widget child;
  final EdgeInsetsGeometry padding;

  static const double _skylineHeight = 84;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppGradients.parchment,
        borderRadius: AppRadius.card,
        border: Border.all(color: context.colors.gold.withValues(alpha: 0.4)),
        boxShadow: AppShadows.sm,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: ExcludeSemantics(
              child: Image.asset(
                BrandAssets.skylineLineArt,
                width: context.screenSize.width * 0.6,
                height: _skylineHeight,
                fit: BoxFit.cover,
                alignment: Alignment.bottomRight,
                opacity: const AlwaysStoppedAnimation(0.3),
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
