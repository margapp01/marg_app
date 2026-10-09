import 'package:flutter/material.dart';

/// Visual style of an [AppIconButton].
enum AppIconButtonVariant { standard, filled, tonal, outlined }

/// A single icon-only action with a mandatory [tooltip] (also used as the
/// semantic label, so every icon button is screen-reader accessible) and a
/// guaranteed ≥48dp touch target.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.variant = AppIconButtonVariant.standard,
    this.color,
    this.size = 24,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Shown on long-press and read by screen readers — never omit it.
  final String tooltip;
  final AppIconButtonVariant variant;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: size);
    final style = color == null ? null : IconButton.styleFrom(foregroundColor: color);
    return switch (variant) {
      AppIconButtonVariant.standard => IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: iconWidget,
          style: style,
        ),
      AppIconButtonVariant.filled => IconButton.filled(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: iconWidget,
          style: style,
        ),
      AppIconButtonVariant.tonal => IconButton.filledTonal(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: iconWidget,
          style: style,
        ),
      AppIconButtonVariant.outlined => IconButton.outlined(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: iconWidget,
          style: style,
        ),
    };
  }
}
