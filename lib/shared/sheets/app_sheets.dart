import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../buttons/app_button.dart';
import '../cards/stat_ledger.dart';
import '../images/illustrated_icon.dart';
import '../tiles/app_list_tile.dart';

/// One action in an [AppSheets.actions] menu.
class SheetAction {
  const SheetAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;
}

/// One option in an [AppSheets.select] picker.
class SheetOption<T> {
  const SheetOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Standard bottom sheets — action menus, single-select pickers, and
/// confirmations. Chrome (drag handle, rounded top) comes from the theme's
/// `bottomSheetTheme`, and every preset is built on [AppSheetLayout], so all
/// sheets share one header, gutter and footer.
abstract final class AppSheets {
  /// Low-level opener; wraps [showModalBottomSheet] with padding + safe area.
  /// Pass `padded: false` when [builder] returns an [AppSheetLayout], which
  /// manages its own header, gutters, keyboard inset and footer.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool padded = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      // Above the shell's bottom navigation, so the footer is never covered.
      useRootNavigator: true,
      isScrollControlled: isScrollControlled,
      builder: (context) => padded
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: builder(context),
              ),
            )
          : builder(context),
    );
  }

  /// A context menu of actions. Tapping one closes the sheet then runs it.
  static Future<void> actions(
    BuildContext context, {
    String? title,
    required List<SheetAction> actions,
  }) {
    return show<void>(
      context,
      padded: false,
      builder: (context) => AppSheetLayout(
        title: title,
        bodyPadding: _listPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final action in actions)
              AppListTile(
                leadingIcon: action.icon,
                title: action.label,
                destructive: action.destructive,
                onTap: () {
                  Navigator.of(context).pop();
                  action.onTap();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// A single-select picker. Resolves to the chosen value, or null if
  /// dismissed.
  static Future<T?> select<T>(
    BuildContext context, {
    required String title,
    required List<SheetOption<T>> options,
    T? selected,
  }) {
    return show<T>(
      context,
      padded: false,
      builder: (context) => AppSheetLayout(
        title: title,
        bodyPadding: _listPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final option in options)
              Semantics(
                selected: option.value == selected,
                child: AppListTile(
                  leadingIcon: option.icon,
                  title: option.label,
                  trailing: Icon(
                    option.value == selected ? AppIcons.success : AppIcons.unchecked,
                    color: option.value == selected ? context.scheme.primary : context.colors.textDisabled,
                  ),
                  onTap: () => Navigator.of(context).pop(option.value),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// A confirmation sheet (alternative to a dialog for lighter-weight
  /// confirmations). Resolves true when confirmed.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final result = await show<bool>(
      context,
      padded: false,
      builder: (context) => AppSheetLayout(
        title: title,
        bodyPadding: message == null ? EdgeInsets.zero : AppSheetLayout.defaultBodyPadding,
        actions: [
          if (destructive)
            AppButton.danger(label: confirmLabel, onPressed: () => Navigator.of(context).pop(true))
          else
            AppButton.primary(label: confirmLabel, onPressed: () => Navigator.of(context).pop(true)),
          AppButton.ghost(label: cancelLabel, expand: true, onPressed: () => Navigator.of(context).pop(false)),
        ],
        child: message == null
            ? const SizedBox.shrink()
            : Text(message, style: context.textTheme.bodyMedium?.withColor(context.colors.textSecondary)),
      ),
    );
    return result ?? false;
  }

  /// Option lists run edge to edge; [AppListTile] brings its own gutter.
  static const EdgeInsets _listPadding = EdgeInsets.symmetric(vertical: AppSpacing.sm);
}

/// The one layout for every sheet (filters, forms, pickers, share, details):
/// a header with an optional [icon] badge, the [title] in the display face,
/// optional [subtitle], optional [trailing] action (e.g. "Reset") and a close
/// button over a gold hairline; a body with the standard gutters; and a
/// pinned footer for [actions]. Lifts above the keyboard and never grows past
/// 90 % of the screen. Open it with `AppSheets.show(padded: false)`.
///
/// The body scrolls by default. Set [scrollable] to false when [child] scrolls
/// itself (e.g. a searchable list) — it then fills the remaining height.
class AppSheetLayout extends StatelessWidget {
  const AppSheetLayout({
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.actions = const [],
    this.bodyPadding = defaultBodyPadding,
    this.scrollable = true,
    super.key,
  });

  /// Header title; when null the sheet has no header (e.g. a bare menu).
  final String? title;
  final String? subtitle;

  /// Header badge — what the sheet is about (a filter, a share, a place).
  final IconData? icon;

  /// Badge tint (defaults to saffron).
  final Color? iconColor;
  final Widget? trailing;
  final Widget child;

  /// Footer buttons, stacked full-width (primary first).
  final List<Widget> actions;
  final EdgeInsets bodyPadding;
  final bool scrollable;

  static const EdgeInsets defaultBodyPadding = EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg);
  static const double _maxHeightFactor = 0.9;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * _maxHeightFactor),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                _SheetHeader(title: title!, subtitle: subtitle, icon: icon, iconColor: iconColor, trailing: trailing),
                const GoldRule(),
              ],
              Flexible(
                child: scrollable
                    ? SingleChildScrollView(padding: bodyPadding, child: child)
                    : Padding(padding: bodyPadding, child: child),
              ),
              if (actions.isNotEmpty) _SheetFooter(actions: actions),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, this.subtitle, this.icon, this.iconColor, this.trailing});

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  static const double _badge = 40;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.xs, AppSpacing.md),
      child: Row(
        children: [
          if (icon != null) ...[
            IllustratedIcon(fallbackIcon: icon!, color: iconColor ?? context.scheme.primary, size: _badge),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: context.displayText.titleLarge.withColor(context.scheme.secondary)),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(subtitle!, style: context.textTheme.bodySmall?.withColor(context.colors.textSecondary)),
                ],
              ],
            ),
          ),
          ?trailing,
          IconButton(
            icon: Icon(AppIcons.close, color: context.colors.textSecondary),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _SheetFooter extends StatelessWidget {
  const _SheetFooter({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.colors.divider))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              actions[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// A labelled group inside an [AppSheetLayout] body — an optional tinted
/// [icon], the label, an optional trailing value, then the group.
class AppSheetSection extends StatelessWidget {
  const AppSheetSection({required this.label, required this.child, this.icon, this.trailing, super.key});

  final String label;
  final Widget child;
  final IconData? icon;

  /// Optional value shown at the end of the label row (e.g. "25 km").
  final Widget? trailing;

  static const double _iconDisc = 28;

  @override
  Widget build(BuildContext context) {
    final accent = context.scheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: _iconDisc,
                  height: _iconDisc,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.12)),
                  child: Icon(icon, size: _iconDisc * 0.55, color: accent, fill: 1),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(label, style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary)),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
