import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/app_notification.dart';
import 'notification_widgets.dart';

/// Date-range options the client can honestly apply over the loaded feed
/// (the list endpoint has no date filter, so this is client-side).
enum DateFilter { allTime, thisWeek, thisMonth, custom }

/// The Activity Feed filter — activity type + date range. Every value maps to a
/// real notification type / a real date window; nothing fabricated.
class ActivityFilter {
  const ActivityFilter({this.type = NotificationFilter.all, this.date = DateFilter.allTime, this.customRange});

  final NotificationFilter type;
  final DateFilter date;
  final DateTimeRange? customRange;

  bool get isDefault => type == NotificationFilter.all && date == DateFilter.allTime;

  ActivityFilter copyWith({NotificationFilter? type, DateFilter? date, DateTimeRange? customRange, bool clearCustom = false}) =>
      ActivityFilter(
        type: type ?? this.type,
        date: date ?? this.date,
        customRange: clearCustom ? null : (customRange ?? this.customRange),
      );

  bool matches(AppNotification n) => type.matches(n) && _dateMatches(n.createdAt);

  bool _dateMatches(DateTime d) {
    final now = DateTime.now();
    switch (date) {
      case DateFilter.allTime:
        return true;
      case DateFilter.thisWeek:
        return d.isAfter(now.subtract(const Duration(days: 7)));
      case DateFilter.thisMonth:
        return d.year == now.year && d.month == now.month;
      case DateFilter.custom:
        final r = customRange;
        if (r == null) return true;
        return !d.isBefore(r.start) && !d.isAfter(r.end.add(const Duration(days: 1)));
    }
  }
}

Future<ActivityFilter?> showActivityFilterSheet(BuildContext context, ActivityFilter current) {
  return AppSheets.show<ActivityFilter>(
    context,
    padded: false,
    builder: (_) => _ActivityFilterSheet(current: current),
  );
}

class _ActivityFilterSheet extends StatefulWidget {
  const _ActivityFilterSheet({required this.current});
  final ActivityFilter current;
  @override
  State<_ActivityFilterSheet> createState() => _ActivityFilterSheetState();
}

class _ActivityFilterSheetState extends State<_ActivityFilterSheet> {
  late ActivityFilter _filter = widget.current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final dates = [
      (DateFilter.allTime, AppIcons.history, l10n.ntAllTime, p.accentSaffron),
      (DateFilter.thisWeek, AppIcons.today, l10n.ntThisWeek, p.accentBlue),
      (DateFilter.thisMonth, AppIcons.calendar, l10n.ntThisMonth, p.accentGreen),
      (DateFilter.custom, AppIcons.tune, l10n.ntCustomRange, p.accentViolet),
    ];
    return AppSheetLayout(
      title: l10n.ntFilterActivity,
      icon: AppIcons.tune,
      trailing: TextButton(onPressed: () => setState(() => _filter = const ActivityFilter()), child: Text(l10n.ntReset)),
      actions: [
        AppButton.primary(label: l10n.ntApplyFilters, icon: AppIcons.check, onPressed: () => Navigator.of(context).pop(_filter)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetSection(
            label: l10n.ntActivityType,
            icon: AppIcons.notifications,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final f in NotificationFilter.values)
                  AppFilterChip(
                    label: _typeLabel(l10n, f),
                    icon: f.kind == null ? AppIcons.inbox : notificationVisual(context, f.kind!).$1,
                    selected: _filter.type == f,
                    onSelected: (_) => setState(() => _filter = _filter.copyWith(type: f)),
                  ),
              ],
            ),
          ),
          AppSheetSection(
            label: l10n.ntDateRange,
            icon: AppIcons.calendar,
            child: Column(
              children: [
                for (final (i, (value, icon, label, accent)) in dates.indexed) ...[
                  if (i > 0) const Gap(AppSpacing.sm),
                  OptionCard(
                    icon: icon,
                    title: label,
                    subtitle: value == DateFilter.custom ? _customLabel(context) : null,
                    accent: accent,
                    radio: true,
                    selected: _filter.date == value,
                    onTap: () => _pickDate(value),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The chosen custom range ("3 Oct – 8 Oct"), or null before one is picked.
  String? _customLabel(BuildContext context) {
    final r = _filter.customRange;
    if (r == null) return null;
    final fmt = DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag());
    return '${fmt.format(r.start)} – ${fmt.format(r.end)}';
  }

  Future<void> _pickDate(DateFilter value) async {
    if (value != DateFilter.custom) {
      setState(() => _filter = _filter.copyWith(date: value, clearCustom: true));
      return;
    }
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _filter.customRange,
    );
    if (picked != null) setState(() => _filter = _filter.copyWith(date: DateFilter.custom, customRange: picked));
  }

  String _typeLabel(AppLocalizations l10n, NotificationFilter f) {
    switch (f) {
      case NotificationFilter.all:
        return l10n.ntAll;
      case NotificationFilter.visits:
        return l10n.ntVisits;
      case NotificationFilter.achievements:
        return l10n.ntAchievements;
      case NotificationFilter.cards:
        return l10n.ntCards;
      case NotificationFilter.routes:
        return l10n.ntRoutes;
      case NotificationFilter.trust:
        return l10n.ntTrust;
      case NotificationFilter.passport:
        return l10n.ntPassport;
      case NotificationFilter.system:
        return l10n.ntSystem;
      case NotificationFilter.marketing:
        return l10n.ntUpdates;
    }
  }
}
