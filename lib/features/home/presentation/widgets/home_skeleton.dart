import 'package:flutter/material.dart';

import '../../../../shared/design_system.dart';

/// Shimmer placeholder shown during the very first Home load (before any data
/// exists). Refreshes keep the real content on screen instead.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: AppSpacing.screenAll,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SkeletonLine(widthFactor: 0.6, height: 22),
          const Gap(AppSpacing.sm),
          const SkeletonLine(widthFactor: 0.4),
          const Gap(AppSpacing.xl),
          const SkeletonBox(height: 52, radius: AppRadius.lgAll),
          const Gap(AppSpacing.xl),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                const Expanded(child: SkeletonBox(height: 84, radius: AppRadius.mdAll)),
                if (i < 2) const Gap.h(AppSpacing.md),
              ],
            ],
          ),
          const Gap(AppSpacing.xl),
          const SkeletonBox(height: 150, radius: AppRadius.lgAll),
          const Gap(AppSpacing.xl),
          const SkeletonCard(hasImage: true),
          const Gap(AppSpacing.lg),
          const SkeletonCard(hasImage: true),
        ],
      ),
    );
  }
}
