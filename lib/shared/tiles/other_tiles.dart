import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../core/extensions/context_extensions.dart';
import '../images/app_avatar.dart';
import 'app_list_tile.dart';

/// A person row: avatar, name, subtitle, optional trailing.
class ProfileTile extends StatelessWidget {
  const ProfileTile({
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String name;
  final String? subtitle;
  final String? imageUrl;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppListTile(
        leading: AppAvatar(imageUrl: imageUrl, name: name, radius: 22),
        title: name,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      );
}

/// A static label → value row for detail/summary lists (no tap by default).
class InfoTile extends StatelessWidget {
  const InfoTile({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => AppListTile(
        leadingIcon: icon,
        title: label,
        dense: true,
        trailing: Text(value, style: context.textTheme.bodyLarge),
      );
}

/// A prominent action row (icon + title), with a [destructive] tone option.
class ActionTile extends StatelessWidget {
  const ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final bool destructive;

  @override
  Widget build(BuildContext context) => AppListTile(
        leadingIcon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        destructive: destructive,
      );
}

/// A drill-in navigation row (icon + title + chevron).
class NavigationTile extends StatelessWidget {
  const NavigationTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => AppListTile(
        leadingIcon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        trailing: const Icon(AppIcons.chevronRight),
      );
}
