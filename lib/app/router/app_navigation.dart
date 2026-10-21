import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// Opens a route by name the right way for its kind: a bottom-tab root is
/// switched to with `goNamed` (pushing a tab-branch route from a root-level
/// page breaks the shell's navigator keys), everything else is pushed.
extension AppNavigation on BuildContext {
  void openNamed(String name, {Map<String, String> pathParameters = const {}, Object? extra}) {
    if (RouteNames.tabRoots.contains(name)) {
      goNamed(name, pathParameters: pathParameters, extra: extra);
    } else {
      pushNamed(name, pathParameters: pathParameters, extra: extra);
    }
  }
}
