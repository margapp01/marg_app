import 'package:flutter/material.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';

/// The notifications bell with the unread count on a saffron badge ("9+"
/// past nine) — the same bell on Home and every tab header.
class NotificationBell extends StatelessWidget {
  const NotificationBell({required this.count, required this.onTap, this.color, super.key});

  final int count;
  final VoidCallback onTap;

  /// Bell colour (defaults to navy).
  final Color? color;

  static const int _max = 9;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      onPressed: onTap,
      tooltip: count > 0 ? '${l10n.titleNotifications}, $count' : l10n.titleNotifications,
      icon: Badge(
        isLabelVisible: count > 0,
        backgroundColor: context.scheme.primary,
        textColor: context.scheme.onPrimary,
        label: Text(count > _max ? '$_max+' : '$count'),
        child: Icon(AppIcons.notifications, color: color ?? context.scheme.secondary),
      ),
    );
  }
}
