import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// The shared dialog surface: an optional tinted icon header, a title, a
/// message, and a vertical stack of action buttons. Use the [AppDialogs]
/// helpers rather than constructing this directly at call sites.
class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    this.message,
    this.icon,
    this.iconColor,
    this.actions = const [],
    this.content,
    super.key,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final Color? iconColor;

  /// Action buttons, stacked full-width (primary first).
  final List<Widget> actions;

  /// Optional custom body between message and actions.
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final tint = iconColor ?? context.scheme.primary;
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Container(
                padding: AppSpacing.allMd,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: AppRadius.fullAll,
                ),
                child: Icon(icon, color: tint, size: 28),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium
                    ?.copyWith(color: context.colors.textSecondary),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: AppSpacing.lg),
              content!,
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                actions[i],
              ],
            ],
          ],
        ),
      ),
    );
  }
}
