import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../core/extensions/context_extensions.dart';
import '../buttons/app_button.dart';
import '../empty/state_art.dart';
import '../empty/state_layout.dart';

/// Full-area error state with an optional retry action. Illustrated by default
/// (the extinguished lamp); pass `art: null` for a compact tinted [icon]
/// badge. For typed failures use the presets in `error_states.dart`.
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.title,
    this.message,
    this.icon = AppIcons.error,
    this.art = StateArt.error,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;
  final StateArt? art;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) => StateLayout(
        title: title,
        message: message,
        icon: icon,
        accent: context.scheme.error,
        art: art,
        action: onRetry == null
            ? null
            : AppButton.primary(
                label: retryLabel ?? 'Try again',
                icon: AppIcons.refresh,
                expand: false,
                onPressed: onRetry,
              ),
      );
}
