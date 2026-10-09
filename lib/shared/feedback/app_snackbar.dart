import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// Feedback intent — drives the snackbar/toast colour and icon.
enum FeedbackType { success, error, warning, info }

/// Themed snackbars via [ScaffoldMessenger]. Prefer these over calling
/// `ScaffoldMessenger` directly so every transient message carries a
/// consistent icon, colour, and shape.
abstract final class AppSnackbar {
  static void success(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) =>
      _show(context, message, FeedbackType.success, actionLabel, onAction);

  static void error(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) =>
      _show(context, message, FeedbackType.error, actionLabel, onAction);

  static void warning(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) =>
      _show(context, message, FeedbackType.warning, actionLabel, onAction);

  static void info(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) =>
      _show(context, message, FeedbackType.info, actionLabel, onAction);

  static (IconData, Color) _style(BuildContext context, FeedbackType type) => switch (type) {
        FeedbackType.success => (AppIcons.success, context.colors.success),
        FeedbackType.error => (AppIcons.error, context.scheme.error),
        FeedbackType.warning => (AppIcons.warning, context.colors.warning),
        FeedbackType.info => (AppIcons.info, context.colors.info),
      };

  static void _show(
    BuildContext context,
    String message,
    FeedbackType type,
    String? actionLabel,
    VoidCallback? onAction,
  ) {
    final (icon, color) = _style(context, type);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.scheme.inverseSurface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
        content: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium
                    ?.copyWith(color: context.scheme.onInverseSurface),
              ),
            ),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: color,
                onPressed: onAction ?? () {},
              ),
      ),
    );
  }
}
