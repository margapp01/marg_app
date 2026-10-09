import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../buttons/app_button.dart';
import 'app_dialog.dart';

/// One entry point for every standard dialog, so confirmations, destructive
/// prompts, and status dialogs look and behave identically everywhere.
abstract final class AppDialogs {
  /// Yes/no confirmation. Resolves to `true` when confirmed, `false`/`null`
  /// otherwise.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    IconData? icon,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: destructive ? context.scheme.error : null,
        actions: [
          destructive
              ? AppButton.danger(
                  label: confirmLabel,
                  onPressed: () => Navigator.of(context).pop(true),
                )
              : AppButton.primary(
                  label: confirmLabel,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
          AppButton.ghost(
            label: cancelLabel,
            expand: true,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Destructive delete confirmation preset.
  static Future<bool> delete(
    BuildContext context, {
    String title = 'Delete?',
    String? message = 'This action cannot be undone.',
    String confirmLabel = 'Delete',
  }) =>
      confirm(
        context,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        icon: AppIcons.delete,
        destructive: true,
      );

  /// Success acknowledgement with a single dismiss button.
  static Future<void> success(
    BuildContext context, {
    required String title,
    String? message,
    String buttonLabel = 'Done',
  }) =>
      _status(context,
          title: title,
          message: message,
          buttonLabel: buttonLabel,
          icon: AppIcons.success,
          color: context.colors.success);

  /// Failure/error acknowledgement.
  static Future<void> failure(
    BuildContext context, {
    required String title,
    String? message,
    String buttonLabel = 'OK',
  }) =>
      _status(context,
          title: title,
          message: message,
          buttonLabel: buttonLabel,
          icon: AppIcons.error,
          color: context.scheme.error);

  /// Neutral information acknowledgement.
  static Future<void> info(
    BuildContext context, {
    required String title,
    String? message,
    String buttonLabel = 'Got it',
  }) =>
      _status(context,
          title: title,
          message: message,
          buttonLabel: buttonLabel,
          icon: AppIcons.info,
          color: context.colors.info);

  /// Blocking loading dialog. Dismiss with `Navigator.of(context).pop()` when
  /// the work completes.
  static Future<void> loading(
    BuildContext context, {
    String message = 'Please wait…',
  }) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AppDialog(
            title: message,
            content: const Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

  static Future<void> _status(
    BuildContext context, {
    required String title,
    required String? message,
    required String buttonLabel,
    required IconData icon,
    required Color color,
  }) =>
      showDialog<void>(
        context: context,
        builder: (context) => AppDialog(
          title: title,
          message: message,
          icon: icon,
          iconColor: color,
          actions: [
            AppButton.primary(
              label: buttonLabel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
}
