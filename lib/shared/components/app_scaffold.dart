import 'package:flutter/material.dart';

import '../app_bar/app_app_bar.dart';
import '../loaders/app_loader.dart';

/// Standard page chrome so global changes happen in one place. Wraps [Scaffold]
/// and adds, opt-in:
/// * a default [AppAppBar] from [title]/[actions] (or a custom [appBar]),
/// * pull-to-refresh via [onRefresh],
/// * a blocking loading overlay via [busy],
/// * safe-area handling.
///
/// For sliver/collapsing layouts, pass your own [CustomScrollView] as [body]
/// with no [appBar]; for the common case this covers it.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.appBar,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.onRefresh,
    this.busy = false,
    this.safeArea = true,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  final Widget body;
  final String? title;

  /// Custom app bar; overrides [title]/[actions] when provided.
  final PreferredSizeWidget? appBar;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  /// When set, wraps the body in a [RefreshIndicator].
  final Future<void> Function()? onRefresh;

  /// Shows a dimmed, non-interactive loading overlay above the content.
  final bool busy;
  final bool safeArea;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (onRefresh != null) {
      content = RefreshIndicator(onRefresh: onRefresh!, child: content);
    }
    if (safeArea) content = SafeArea(child: content);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar ??
          (title == null
              ? null
              : AppAppBar(title: title, actions: actions, leading: leading)),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          content,
          if (busy)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: AnimatedLoader(),
              ),
            ),
        ],
      ),
    );
  }
}
