import 'package:flutter/material.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import 'notification_bell.dart';

/// The header of a bottom-tab root screen: ☰ menu · serif title · 🔔 bell,
/// with an optional greeting line underneath. Sits under the status bar
/// (no app bar), matching the Home hero's chrome.
class TabHeader extends StatelessWidget {
  const TabHeader({
    required this.title,
    required this.onMenu,
    required this.onNotifications,
    this.subtitle,
    this.trailing,
    this.notificationCount = 0,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onMenu;
  final VoidCallback onNotifications;

  /// Extra action shown before the bell (e.g. Discover).
  final Widget? trailing;

  /// Unread notifications, badged on the bell.
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final navy = context.scheme.secondary;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xs, context.viewPadding.top + AppSpacing.xs, AppSpacing.xs, AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: Icon(AppIcons.menu, color: navy), tooltip: l10n.homeMenu, onPressed: onMenu),
              if (trailing != null) const SizedBox(width: 48),
              Expanded(
                child: Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.displayText.headlineSmall),
              ),
              ?trailing,
              NotificationBell(count: notificationCount, onTap: onNotifications),
            ],
          ),
          if (subtitle != null)
            Text(subtitle!, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }
}
