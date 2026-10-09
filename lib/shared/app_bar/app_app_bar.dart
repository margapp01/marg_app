import 'package:flutter/material.dart';

import '../components/app_search_bar.dart';

/// The standard top app bar. [transparent] drops the fill (for content that
/// scrolls under it, e.g. over a banner). Implements [PreferredSizeWidget] so
/// it drops straight into `Scaffold.appBar` / [AppScaffold].
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.transparent = false,
    this.centerTitle = false,
    this.bottom,
    super.key,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool transparent;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title == null ? null : Text(title!)),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      bottom: bottom,
      backgroundColor: transparent ? Colors.transparent : null,
      elevation: 0,
      scrolledUnderElevation: transparent ? 0 : null,
    );
  }
}

/// A collapsible sliver app bar for scrollable pages — an expanded header
/// (image/banner via [flexibleSpace]) that shrinks to a standard bar. Use
/// inside a [CustomScrollView].
class AppSliverAppBar extends StatelessWidget {
  const AppSliverAppBar({
    required this.title,
    this.expandedHeight = 220,
    this.flexibleSpace,
    this.actions,
    this.pinned = true,
    super.key,
  });

  final String title;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      expandedHeight: expandedHeight,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(title),
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
        background: flexibleSpace,
      ),
    );
  }
}

/// An app bar whose title area is a search field — search screens / list
/// filtering. Implements [PreferredSizeWidget].
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    required this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.leading,
    this.autofocus = true,
    super.key,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? leading;
  final bool autofocus;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      titleSpacing: leading == null ? 16 : 0,
      title: AppSearchBar(
        hint: hint,
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
