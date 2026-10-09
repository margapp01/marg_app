import 'package:flutter/material.dart';

import '../buttons/app_button.dart';

/// Primary call-to-action. Thin alias over [AppButton.primary], kept for
/// readable call sites; new code may use either.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) => AppButton.primary(
        label: label,
        onPressed: onPressed,
        busy: busy,
        icon: icon,
        expand: expand,
      );
}
