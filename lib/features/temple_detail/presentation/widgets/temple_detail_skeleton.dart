import 'package:flutter/material.dart';

import '../../../../shared/design_system.dart';

/// Shimmer placeholder for the first Temple Detail load.
class TempleDetailSkeleton extends StatelessWidget {
  const TempleDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          const SkeletonBox(height: 300, radius: BorderRadius.zero),
          Padding(
            padding: AppSpacing.screenAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(height: 64, radius: AppRadius.lgAll),
                const Gap(AppSpacing.lg),
                const SkeletonBox(height: 140, radius: AppRadius.lgAll),
                const Gap(AppSpacing.lg),
                const SkeletonLine(widthFactor: 0.4, height: 16),
                const Gap(AppSpacing.md),
                const SkeletonBox(height: 96, radius: AppRadius.lgAll),
                const Gap(AppSpacing.lg),
                const SkeletonBox(height: 96, radius: AppRadius.lgAll),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
