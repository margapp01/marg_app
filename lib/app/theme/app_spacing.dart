import 'package:flutter/widgets.dart';

/// Spacing tokens (4pt-based scale). Use these instead of magic numbers so
/// density can be tuned globally. Never pass raw numbers to [EdgeInsets] or
/// [SizedBox] — reach for a token here (or the [Gap] helper below).
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double huge2 = 48;
  static const double huge3 = 56;
  static const double huge4 = 64;
  static const double huge5 = 80;
  static const double huge6 = 96;

  // ── Common edge insets ────────────────────────────────────────────────
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  /// Standard screen gutters.
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets screenAll = EdgeInsets.all(lg);
}

/// A fixed gap sized from [AppSpacing]. `Gap(x)` follows its parent's main
/// axis — vertical inside a `Column`/vertical list, horizontal inside a
/// `Row`/horizontal list — so it is always the spacing between siblings.
/// `Gap.h(x)` is always horizontal.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key}) : _horizontal = false;
  const Gap.h(this.size, {super.key}) : _horizontal = true;

  final double size;
  final bool _horizontal;

  /// The main axis of the nearest enclosing flex or scroll viewport.
  static Axis _parentAxis(BuildContext context) {
    var axis = Axis.vertical;
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is Flex) {
        axis = widget.direction;
        return false;
      }
      if (widget is Viewport) {
        axis = axisDirectionToAxis(widget.axisDirection);
        return false;
      }
      if (widget is ShrinkWrappingViewport) {
        axis = axisDirectionToAxis(widget.axisDirection);
        return false;
      }
      return true;
    });
    return axis;
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = _horizontal || _parentAxis(context) == Axis.horizontal;
    return horizontal ? SizedBox(width: size) : SizedBox(height: size);
  }
}
