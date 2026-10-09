import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/constants/brand_assets.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// One destination in [AppBottomNav]. [icon] shows when unselected;
/// [selectedIcon] (optional, e.g. a filled variant) shows when active.
class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}

/// The app's primary bottom navigation: an ivory bar with rounded top corners,
/// a gold rim and a faint temple-skyline ornament; navy tabs with a saffron
/// diamond under the active one.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Height of the bar itself (excluding the system inset).
  static const double barHeight = 66;

  void _select(int index) {
    if (index != currentIndex) HapticFeedback.selectionClick();
    onDestinationSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    return SizedBox(
      height: barHeight + inset,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BarPainter(
                top: context.palette.heroCream,
                bottom: context.colors.card,
                rim: context.colors.gold,
                shadow: context.scheme.secondary,
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: AppRadius.topXl,
                child: _SkylineOrnament(height: barHeight),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: barHeight,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavTab(
                      item: items[i],
                      active: i == currentIndex,
                      onTap: () => _select(i),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Outline of the bar: a straight top edge with rounded left/right corners.
abstract final class _BarShape {
  static const double _corner = AppRadius.xl;

  /// The top edge only, [inset] pixels inside the outline (for the inner rim).
  static Path contour(Size size, [double inset = 0]) {
    final radius = Radius.circular(_corner - inset);
    return Path()
      ..moveTo(inset, _corner)
      ..arcToPoint(Offset(_corner, inset), radius: radius)
      ..lineTo(size.width - _corner, inset)
      ..arcToPoint(Offset(size.width - inset, _corner), radius: radius);
  }

  static Path fill(Size size) => contour(size)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();
}

class _BarPainter extends CustomPainter {
  const _BarPainter({
    required this.top,
    required this.bottom,
    required this.rim,
    required this.shadow,
  });

  final Color top;
  final Color bottom;
  final Color rim;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final body = _BarShape.fill(size);
    canvas.drawShadow(body, shadow.withValues(alpha: 0.35), 6, false);
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(Offset.zero & size),
    );
    // Double gold filigree rim following the rounded top edge.
    canvas.drawPath(
      _BarShape.contour(size),
      Paint()
        ..color = rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawPath(
      _BarShape.contour(size, AppSpacing.xs),
      Paint()
        ..color = rim.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.top != top || old.bottom != bottom || old.rim != rim || old.shadow != shadow;
}

/// Faint saffron temple skylines tucked into both corners of the bar.
class _SkylineOrnament extends StatelessWidget {
  const _SkylineOrnament({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final width = context.screenSize.width * 0.42;
    Widget skyline() => Image.asset(
          BrandAssets.skylineLineArt,
          width: width,
          height: height,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          opacity: const AlwaysStoppedAnimation(0.11),
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        );
    return Stack(
      children: [
        Positioned(left: 0, top: 0, child: skyline()),
        Positioned(right: 0, top: 0, child: Transform.flip(flipX: true, child: skyline())),
      ],
    );
  }
}

/// One tab — navy icon + label, with a saffron diamond under the active one.
class _NavTab extends StatelessWidget {
  const _NavTab({required this.item, required this.active, required this.onTap});

  final AppNavItem item;
  final bool active;
  final VoidCallback onTap;

  static const double _iconBox = 28;

  @override
  Widget build(BuildContext context) {
    final navy = context.scheme.secondary;
    final labelStyle = context.textTheme.labelSmall?.copyWith(
      color: active ? navy : context.colors.textSecondary,
      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
    );
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        highlightShape: BoxShape.circle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: _iconBox,
              child: AnimatedScale(
                scale: active ? 1.08 : 1,
                duration: AppDurations.fast,
                child: Icon(
                  active ? item.selectedIcon ?? item.icon : item.icon,
                  size: 26,
                  fill: active ? 1 : 0,
                  color: active ? navy : navy.withValues(alpha: 0.7),
                ),
              ),
            ),
            const Gap(AppSpacing.xs),
            AnimatedDefaultTextStyle(
              duration: AppDurations.fast,
              style: labelStyle ?? const TextStyle(),
              child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Gap(AppSpacing.xxs),
            _ActiveMark(visible: active),
          ],
        ),
      ),
    );
  }
}

/// ─◆─ under the active label.
class _ActiveMark extends StatelessWidget {
  const _ActiveMark({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final color = context.scheme.primary;
    final line = Container(width: AppSpacing.sm, height: 1, color: color.withValues(alpha: 0.6));
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: AppDurations.normal,
      child: SizedBox(
        height: AppSpacing.sm,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            line,
            const Gap.h(AppSpacing.xxs),
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(width: AppSpacing.xs + 1, height: AppSpacing.xs + 1, color: color),
            ),
            const Gap.h(AppSpacing.xxs),
            line,
          ],
        ),
      ),
    );
  }
}
