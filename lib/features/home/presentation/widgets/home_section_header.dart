import 'package:flutter/material.dart';

import '../../../../shared/design_system.dart';

/// Standard "Section Title  ·  View All" row used above every Home section.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.onViewAll,
    this.viewAllLabel,
    super.key,
  });

  final String title;
  final VoidCallback? onViewAll;
  final String? viewAllLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.scheme.secondary,
              ),
            ),
          ),
          if (onViewAll != null)
            InkWell(
              onTap: onViewAll,
              borderRadius: AppRadius.smAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                child: Text(
                  viewAllLabel ?? 'View All',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
