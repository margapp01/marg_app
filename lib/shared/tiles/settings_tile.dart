import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../core/extensions/context_extensions.dart';
import 'app_list_tile.dart';

/// A settings row. Three shapes via named constructors:
/// * [SettingsTile.navigation] — chevron, drills into a sub-page.
/// * [SettingsTile.toggle] — trailing [Switch].
/// * [SettingsTile.value] — shows a current value, with a chevron only when
///   it can be changed ([onTap] set); without [onTap] it is read-only info.
class SettingsTile extends StatelessWidget {
  const SettingsTile.navigation({
    required this.icon,
    required this.title,
    this.subtitle,
    required VoidCallback this.onTap,
    this.iconColor,
    this.destructive = false,
    super.key,
  })  : trailing = null,
        value = null,
        switchValue = null,
        onToggle = null;

  const SettingsTile.toggle({
    required this.icon,
    required this.title,
    this.subtitle,
    required bool this.switchValue,
    required ValueChanged<bool> this.onToggle,
    this.iconColor,
    super.key,
  })  : trailing = null,
        destructive = false,
        value = null,
        onTap = null;

  const SettingsTile.value({
    required this.icon,
    required this.title,
    required String this.value,
    this.subtitle,
    this.onTap,
    this.iconColor,
    super.key,
  })  : trailing = null,
        destructive = false,
        switchValue = null,
        onToggle = null;

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final String? value;
  final bool? switchValue;
  final ValueChanged<bool>? onToggle;
  final Widget? trailing;

  /// Tint of the leading icon chip (defaults to saffron).
  final Color? iconColor;

  /// Red tone for irreversible actions (e.g. delete account).
  final bool destructive;

  static const double _chevronSize = 24;

  @override
  Widget build(BuildContext context) {
    final Widget? trailingWidget;
    if (switchValue != null) {
      trailingWidget = Switch(value: switchValue!, onChanged: onToggle);
    } else if (value != null) {
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value!,
            style: context.textTheme.bodyMedium
                ?.copyWith(color: context.colors.textSecondary),
          ),
          // Read-only values keep the chevron's slot so every value in a
          // group lines up on the same right edge.
          if (onTap != null)
            Icon(AppIcons.chevronRight, color: context.colors.textSecondary, size: _chevronSize)
          else
            const SizedBox(width: _chevronSize),
        ],
      );
    } else {
      trailingWidget = Icon(AppIcons.chevronRight, color: context.colors.textSecondary, size: _chevronSize);
    }
    return AppListTile(
      leadingIcon: icon,
      iconColor: iconColor,
      destructive: destructive,
      title: title,
      subtitle: subtitle,
      trailing: trailingWidget,
      onTap: switchValue != null
          ? () => onToggle?.call(!switchValue!)
          : onTap,
    );
  }
}
