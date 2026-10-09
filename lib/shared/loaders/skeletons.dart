import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../components/app_card.dart';
import 'shimmer.dart';

/// A single card-shaped placeholder (avatar + two lines), shimmering.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({this.hasImage = false, super.key});

  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage) ...[
              const SkeletonBox(height: 120, radius: AppRadius.mdAll),
              const SizedBox(height: AppSpacing.lg),
            ],
            Row(
              children: [
                const SkeletonCircle(),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLine(widthFactor: 0.6),
                      SizedBox(height: AppSpacing.sm),
                      SkeletonLine(widthFactor: 0.9),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A vertical list of [count] shimmering card skeletons.
class SkeletonList extends StatelessWidget {
  const SkeletonList({this.count = 5, this.hasImage = false, this.padding, super.key});

  final int count;
  final bool hasImage;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? AppSpacing.screenAll,
      itemCount: count,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => SkeletonCard(hasImage: hasImage),
    );
  }
}

/// A circular avatar placeholder, shimmering.
class SkeletonAvatar extends StatelessWidget {
  const SkeletonAvatar({this.radius = 22, super.key});

  final double radius;

  @override
  Widget build(BuildContext context) =>
      AppShimmer(child: SkeletonCircle(diameter: radius * 2));
}

/// A wide banner/hero placeholder, shimmering.
class SkeletonBanner extends StatelessWidget {
  const SkeletonBanner({this.height = 160, super.key});

  final double height;

  @override
  Widget build(BuildContext context) => AppShimmer(
        child: SkeletonBox(height: height, radius: AppRadius.lgAll),
      );
}
