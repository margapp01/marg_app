import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_radius.dart';
import '../../core/extensions/context_extensions.dart';

/// Wraps [child] in a themed shimmer sweep. Compose skeleton boxes inside a
/// single [AppShimmer] so the whole placeholder shimmers as one surface.
class AppShimmer extends StatelessWidget {
  const AppShimmer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.scheme.surfaceContainerHighest,
      highlightColor: context.colors.card,
      child: child,
    );
  }
}

/// A solid placeholder block. On its own it is static; wrap in [AppShimmer]
/// (or use the pre-composed skeleton widgets) to animate.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height = 16,
    this.radius = AppRadius.smAll,
    super.key,
  });

  final double? width;
  final double height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerHighest,
        borderRadius: radius,
      ),
    );
  }
}

/// A text-line placeholder; [widthFactor] shortens the last line naturally.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({this.widthFactor = 1, this.height = 12, super.key});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widthFactor,
        child: SkeletonBox(height: height),
      );
}

/// A circular placeholder — avatars, icons.
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({this.diameter = 44, super.key});

  final double diameter;

  @override
  Widget build(BuildContext context) => Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: context.scheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
      );
}
