import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// The canonical list row. A themed wrapper over [ListTile] with a leading
/// icon in a tinted chip, consistent spacing, an optional [destructive] tone,
/// and a guaranteed tap target. All tiles (settings, profile, action,
/// navigation, info) build on this.
class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leading,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.destructive = false,
    this.dense = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool destructive;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final tint = destructive
        ? context.scheme.error
        : (iconColor ?? context.scheme.primary);
    final leadingWidget = leading ??
        (leadingIcon == null
            ? null
            : Container(
                padding: AppSpacing.allSm,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: AppRadius.thumb,
                ),
                child: Icon(leadingIcon, color: tint, size: 20),
              ));
    return ListTile(
      onTap: onTap,
      dense: dense,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: leadingWidget,
      title: Text(
        title,
        style: context.textTheme.bodyLarge?.copyWith(
          color: destructive ? context.scheme.error : null,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.textSecondary),
            ),
      trailing: trailing,
    );
  }
}
