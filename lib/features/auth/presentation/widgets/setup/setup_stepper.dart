import 'package:flutter/material.dart';

import '../../../../../shared/design_system.dart';

/// Segmented onboarding progress: one rounded bar per step, saffron up to and
/// including the [current] step.
class SetupProgress extends StatelessWidget {
  const SetupProgress({required this.current, required this.total, super.key});

  /// Zero-based index of the active step.
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: AppDurations.normal,
              curve: AppCurves.standard,
              height: 5,
              decoration: BoxDecoration(
                color: i <= current ? context.scheme.primary : context.colors.border,
                borderRadius: AppRadius.fullAll,
              ),
            ),
          ),
          if (i < total - 1) const Gap.h(AppSpacing.xs),
        ],
      ],
    );
  }
}
