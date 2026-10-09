import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// Visual weight of a button.
enum AppButtonVariant {
  /// Filled saffron — the single primary action on a screen.
  primary,

  /// Tonal (deep-blue container) — secondary action.
  secondary,

  /// Bordered, transparent fill.
  outlined,

  /// Text-only, no fill or border.
  ghost,

  /// Filled error — destructive confirmation.
  danger,
}

/// Button height/typography scale.
enum AppButtonSize { small, medium, large }

/// The one button in the design system. Every labelled action uses this (or a
/// named constructor), so weight, size, loading, disabled, and success states
/// look identical everywhere.
///
/// States: `onPressed == null` → disabled · [busy] → spinner + disabled ·
/// [success] → check + success colour (kept when disabled — a done state).
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.busy = false,
    this.success = false,
    this.expand = true,
    super.key,
  });

  const AppButton.primary({
    required String label,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool busy = false,
    bool success = false,
    bool expand = true,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.primary,
          size: size,
          icon: icon,
          busy: busy,
          success: success,
          expand: expand,
          key: key,
        );

  const AppButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool busy = false,
    bool expand = true,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.secondary,
          size: size,
          icon: icon,
          busy: busy,
          expand: expand,
          key: key,
        );

  const AppButton.outlined({
    required String label,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool busy = false,
    bool expand = true,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.outlined,
          size: size,
          icon: icon,
          busy: busy,
          expand: expand,
          key: key,
        );

  const AppButton.ghost({
    required String label,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool expand = false,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.ghost,
          size: size,
          icon: icon,
          expand: expand,
          key: key,
        );

  const AppButton.danger({
    required String label,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool busy = false,
    bool expand = true,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.danger,
          size: size,
          icon: icon,
          busy: busy,
          expand: expand,
          key: key,
        );

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;

  /// Shows a spinner and blocks taps.
  final bool busy;

  /// Shows a success check and success colouring (e.g. after save).
  final bool success;

  /// Stretches to the parent's full width (mobile CTA default). Set false
  /// inside a [Row] without an [Expanded] wrapper.
  final bool expand;

  double get _height => switch (size) {
        AppButtonSize.small => 40,
        AppButtonSize.medium => 48,
        AppButtonSize.large => 56,
      };

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final child = _buildChild(context);
    final minimumSize = Size(expand ? double.infinity : 0, _height);
    final shape = const RoundedRectangleBorder(borderRadius: AppRadius.control);
    final padding = EdgeInsets.symmetric(
      horizontal: size == AppButtonSize.small ? AppSpacing.lg : AppSpacing.xl,
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            minimumSize: minimumSize,
            shape: shape,
            padding: padding,
            backgroundColor: success ? context.colors.success : null,
            // A completed action is usually also inert — keep it green, not grey.
            disabledBackgroundColor: success ? context.colors.success : null,
            disabledForegroundColor: success ? context.scheme.onPrimary : null,
          ),
          child: child,
        ),
      AppButtonVariant.secondary => FilledButton.tonal(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            minimumSize: minimumSize,
            shape: shape,
            padding: padding,
          ),
          child: child,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            minimumSize: minimumSize,
            shape: shape,
            padding: padding,
          ),
          child: child,
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(
            minimumSize: minimumSize,
            shape: shape,
            padding: padding,
          ),
          child: child,
        ),
      AppButtonVariant.danger => FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            minimumSize: minimumSize,
            shape: shape,
            padding: padding,
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.onPrimary,
          ),
          child: child,
        ),
    };
    return button;
  }

  Widget _buildChild(BuildContext context) {
    if (busy) {
      return SizedBox.square(
        dimension: size == AppButtonSize.small ? 16 : 20,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    final effectiveLeading = success ? AppIcons.check : icon;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (effectiveLeading != null) ...[
          Icon(effectiveLeading, size: 18),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(trailingIcon, size: 18),
        ],
      ],
    );
  }
}
