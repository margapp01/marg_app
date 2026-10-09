import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';

/// Carousel position indicator: the active dot stretches into a pill.
class PageDots extends StatelessWidget {
  const PageDots({required this.count, required this.index, super.key});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Semantics(
      label: '${index + 1} of $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppDurations.fast,
              curve: AppCurves.standard,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              width: i == index ? AppSpacing.lg : AppSpacing.sm - 2,
              height: AppSpacing.sm - 2,
              decoration: BoxDecoration(
                color: i == index ? context.scheme.primary : context.colors.border,
                borderRadius: AppRadius.fullAll,
              ),
            ),
        ],
      ),
    );
  }
}
