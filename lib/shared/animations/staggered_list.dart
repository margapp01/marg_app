import 'package:flutter/widgets.dart';

import '../../app/theme/app_durations.dart';
import 'app_entrance.dart';

/// Wraps each child in a staggered slide+fade entrance, so a column/list of
/// items cascades in. Purely presentational — compose inside a [Column],
/// [ListView] (via `children`), or [Wrap].
class StaggeredList extends StatelessWidget {
  const StaggeredList({
    required this.children,
    this.stagger = AppDurations.stagger,
    this.initialDelay = Duration.zero,
    this.itemDuration = AppDurations.normal,
    super.key,
  });

  final List<Widget> children;
  final Duration stagger;
  final Duration initialDelay;
  final Duration itemDuration;

  /// Applies the stagger to an arbitrary list — reusable by builders that
  /// already own their [Column]/[ListView].
  static List<Widget> wrap(
    List<Widget> children, {
    Duration stagger = AppDurations.stagger,
    Duration initialDelay = Duration.zero,
    Duration itemDuration = AppDurations.normal,
  }) {
    return <Widget>[
      for (var i = 0; i < children.length; i++)
        SlideIn(
          delay: initialDelay + stagger * i,
          duration: itemDuration,
          child: children[i],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: wrap(
        children,
        stagger: stagger,
        initialDelay: initialDelay,
        itemDuration: itemDuration,
      ),
    );
  }
}
