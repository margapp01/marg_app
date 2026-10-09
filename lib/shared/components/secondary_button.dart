import 'package:flutter/material.dart';

import '../buttons/app_button.dart';

/// Secondary action. Thin alias over [AppButton.secondary], kept for readable
/// call sites; new code may use either.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) => AppButton.secondary(
        label: label,
        onPressed: onPressed,
        icon: icon,
        expand: expand,
      );
}
