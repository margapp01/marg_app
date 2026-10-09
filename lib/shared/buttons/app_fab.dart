import 'package:flutter/material.dart';

/// Floating action button for the screen's single most important action.
/// Collapses to an icon-only FAB, or an extended FAB when [label] is given.
class AppFab extends StatelessWidget {
  const AppFab({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.label,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Semantic label / tooltip — required for accessibility.
  final String tooltip;

  /// When set, renders an extended FAB with text beside the icon.
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon),
        label: Text(label!),
      );
    }
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
