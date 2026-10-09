import 'package:flutter/material.dart';

import '../../../../../shared/design_system.dart';

/// Centered serif title + subtitle at the top of each setup step.
class SetupHeader extends StatelessWidget {
  const SetupHeader({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, textAlign: TextAlign.center, style: context.displayText.headlineSmall),
        const Gap(AppSpacing.xs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
        ),
      ],
    );
  }
}

/// A field with an external label above it (matches the onboarding forms).
class LabeledField extends StatelessWidget {
  const LabeledField({required this.label, required this.child, this.hint, super.key});

  final String label;

  /// Optional muted note after the label, e.g. "(Select any)".
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: context.textTheme.labelLarge?.semiBold.withColor(context.scheme.secondary),
            children: [
              if (hint != null)
                TextSpan(
                  text: ' $hint',
                  style: context.textTheme.labelMedium?.copyWith(color: context.colors.textSecondary),
                ),
            ],
          ),
        ),
        const Gap(AppSpacing.sm),
        child,
      ],
    );
  }
}
