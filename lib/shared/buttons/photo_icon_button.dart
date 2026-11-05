import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// A round, translucent icon button that stays legible over a photo — the
/// back and share actions on a hero image (Temple Detail, festivals, stories).
class PhotoIconButton extends StatelessWidget {
  const PhotoIconButton({required this.icon, required this.tooltip, required this.onPressed, super.key});

  final IconData icon;

  /// Shown on long-press and read by screen readers.
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.black.withValues(alpha: 0.35),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Padding(
              padding: AppSpacing.allSm,
              child: Icon(icon, size: 20, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
