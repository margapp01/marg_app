import 'package:flutter/material.dart';

import '../../app/theme/app_durations.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// The app's one search input — a white pill with a soft shadow, a muted
/// search glyph, the hint, and an optional saffron [trailing] action (filter,
/// tune…). Used everywhere search appears so it looks identical on every
/// screen.
///
/// Two modes:
/// * **Entry** — pass [onTap]: a read-only pill that opens a search screen
///   (Home, Explore).
/// * **Field** — no [onTap]: a live text field with an animated clear button.
///
/// Give the entry pill and the destination field the same [heroTag] (see
/// [heroTagFor]) and the pill glides into the search header when the screen
/// opens. With [autofocus] the keyboard
/// waits for that page transition to finish, so the motion stays smooth.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    required this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.trailing,
    this.heroTag,
    this.autofocus = false,
    this.elevated = true,
    super.key,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  /// Makes this a read-only entry pill that runs [onTap] when pressed.
  final VoidCallback? onTap;

  /// Optional action at the end of the pill (e.g. a filter [IconButton]).
  final Widget? trailing;
  final Object? heroTag;
  final bool autofocus;

  /// Floating shadow (on page backgrounds) vs. a hairline border (inside app
  /// bars and cards).
  final bool elevated;

  /// Height shared by every search pill.
  static const double height = 52;

  /// Hero tag linking an entry pill on [origin] (e.g. `home`, `explore`) to
  /// the Search screen. Tags are per-origin because tab pages stay alive in
  /// the shell, and two live heroes may never share a tag.
  static String heroTagFor(String origin) => 'marg-search-$origin';

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  TextEditingController? _ownController;
  final _focus = FocusNode();
  Animation<double>? _routeAnimation;

  bool get _isEntry => widget.onTap != null;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    if (!_isEntry) _controller.addListener(_onTextChanged);
    if (widget.autofocus && !_isEntry) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusAfterTransition());
    }
  }

  void _onTextChanged() => setState(() {});

  /// Opening the keyboard mid-transition makes the page jump; wait until the
  /// route has settled.
  void _focusAfterTransition() {
    if (!mounted) return;
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) {
      _focus.requestFocus();
      return;
    }
    _routeAnimation = animation..addStatusListener(_onRouteStatus);
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _routeAnimation = null;
    if (mounted) _focus.requestFocus();
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    if (!_isEntry) _controller.removeListener(_onTextChanged);
    _ownController?.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final hintStyle = context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary);
    final Widget input = _isEntry
        ? Text(widget.hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: hintStyle)
        : TextField(
            controller: _controller,
            focusNode: _focus,
            textInputAction: TextInputAction.search,
            style: context.textTheme.bodyLarge,
            cursorColor: context.scheme.primary,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              isCollapsed: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: widget.hint,
              hintStyle: hintStyle,
            ),
          );

    final pill = _SearchPill(
      elevated: widget.elevated,
      onTap: widget.onTap,
      semanticLabel: _isEntry ? widget.hint : null,
      input: input,
      actions: [
        if (!_isEntry)
          AnimatedSwitcher(
            duration: AppDurations.fast,
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: _controller.text.isNotEmpty
                ? IconButton(
                    key: const ValueKey('clear'),
                    tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                    icon: Icon(AppIcons.close, color: context.colors.textSecondary),
                    onPressed: _clear,
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ?widget.trailing,
      ],
    );

    final tag = widget.heroTag;
    if (tag == null) return pill;
    return Hero(
      tag: tag,
      // Fly a static copy: a live TextField must not be rebuilt in the overlay.
      flightShuttleBuilder: (_, _, _, _, _) => _SearchPill(
        elevated: widget.elevated,
        input: Text(widget.hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: hintStyle),
        actions: [?widget.trailing],
      ),
      child: pill,
    );
  }
}

/// The visual shell shared by the entry pill, the live field and the hero
/// shuttle, so all three are pixel-identical.
class _SearchPill extends StatelessWidget {
  const _SearchPill({
    required this.elevated,
    required this.input,
    required this.actions,
    this.onTap,
    this.semanticLabel,
  });

  final bool elevated;
  final Widget input;
  final List<Widget> actions;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          boxShadow: elevated ? AppShadows.md : AppShadows.none,
        ),
        child: Material(
          color: context.colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgAll,
            side: elevated ? BorderSide.none : BorderSide(color: context.colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: AppSearchBar.height,
              child: Row(
                children: [
                  const Gap.h(AppSpacing.lg),
                  Icon(AppIcons.search, color: context.colors.textSecondary),
                  const Gap.h(AppSpacing.md),
                  Expanded(child: input),
                  ...actions,
                  Gap.h(actions.isEmpty ? AppSpacing.lg : AppSpacing.xs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A saffron icon action for the end of an [AppSearchBar] (filter, tune…).
class SearchBarAction extends StatelessWidget {
  const SearchBarAction({required this.icon, required this.tooltip, required this.onPressed, super.key});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, color: context.scheme.primary),
        tooltip: tooltip,
        onPressed: onPressed,
      );
}
