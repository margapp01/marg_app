import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../core/extensions/context_extensions.dart';
import 'state_art.dart';
import 'state_layout.dart';

/// Full-area empty state for lists with no content yet. Pass an [art] scene for
/// the illustrated look (serif title + lotus rule); without one it falls back
/// to a tinted [icon] badge. Content animates in so an empty screen still feels
/// intentional. For common screens use the presets in `empty_states.dart`.
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.title,
    this.message,
    this.icon = AppIcons.inbox,
    this.iconColor,
    this.art,
    this.action,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Color? iconColor;
  final StateArt? art;
  final Widget? action;

  @override
  Widget build(BuildContext context) => StateLayout(
        title: title,
        message: message,
        icon: icon,
        accent: iconColor ?? context.scheme.primary,
        art: art,
        action: action,
      );
}
