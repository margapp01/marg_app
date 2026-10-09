import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';

/// A phase body: scrollable content above a pinned action area.
class VisitPhaseBody extends StatelessWidget {
  const VisitPhaseBody({required this.content, required this.actions, super.key});

  final List<Widget> content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(padding: AppSpacing.screenAll, children: content),
          ),
          Padding(
            padding: AppSpacing.screenAll,
            child: Column(mainAxisSize: MainAxisSize.min, children: actions),
          ),
        ],
      ),
    );
  }
}

/// The temple at the head of a visit step, on parchment: its photo in a gold
/// edge, an optional gold [label] ("Destination", "Checking in at"), the
/// name in the display serif and its place. Reused across steps so the
/// temple's identity stays constant.
class VisitTempleBanner extends StatelessWidget {
  const VisitTempleBanner({required this.name, this.label, this.location, this.imageUrl, super.key});

  final String name;
  final String? label;
  final String? location;
  final String? imageUrl;

  static const double _thumb = 64;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    final location = this.location;
    final imageUrl = this.imageUrl;
    final fallback = ColoredBox(
      color: context.colors.templeSand,
      child: Icon(AppIcons.temple, color: context.colors.templeStone),
    );
    return ParchmentCard(
      padding: AppSpacing.allMd,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.thumb,
              border: Border.all(color: context.colors.gold, width: 1.5),
              boxShadow: AppShadows.sm,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.thumb,
              child: SizedBox.square(
                dimension: _thumb,
                child: imageUrl == null
                    ? fallback
                    : AppNetworkImage(url: imageUrl, fit: BoxFit.cover, fallback: fallback),
              ),
            ),
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null) ...[
                  Text(
                    label.toUpperCase(),
                    style: context.overline.copyWith(color: context.colors.gold, letterSpacing: 1.4),
                  ),
                  const Gap(AppSpacing.xxs),
                ],
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.displayText.titleLarge.withColor(context.scheme.secondary),
                ),
                if (location != null && location.isNotEmpty) ...[
                  const Gap(AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(AppIcons.location, size: 14, color: context.colors.gold, fill: 1),
                      const Gap.h(AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.caption.copyWith(color: context.colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A tinted disc holding an icon — the leading mark of check rows and reward
/// tiles.
class VisitIconDisc extends StatelessWidget {
  const VisitIconDisc({required this.icon, required this.color, this.size = 40, super.key});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
      child: Icon(icon, size: size * 0.5, color: color, fill: 1),
    );
  }
}

/// One reward of the visit on the success summary — a mark, what was
/// earned and its detail. With [onTap] it opens that reward's own screen.
class VisitRewardRow extends StatelessWidget {
  const VisitRewardRow({
    required this.leading,
    required this.title,
    this.detail,
    this.detailColor,
    this.onTap,
    super.key,
  });

  final Widget leading;
  final String title;
  final String? detail;
  final Color? detailColor;
  final VoidCallback? onTap;

  static const double _lead = 44;

  @override
  Widget build(BuildContext context) {
    final detail = this.detail;
    return Semantics(
      button: onTap != null,
      label: detail == null ? title : '$title, $detail',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.control,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              SizedBox.square(
                dimension: _lead,
                child: Center(child: leading),
              ),
              const Gap.h(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary),
                    ),
                    if (detail != null && detail.isNotEmpty) ...[
                      const Gap(AppSpacing.xxs),
                      Text(
                        detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.caption.semiBold.copyWith(color: detailColor ?? context.colors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null) ...[
                const Gap.h(AppSpacing.sm),
                Icon(AppIcons.chevronRight, color: context.colors.gold),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rows on one parchment ledger, divided by gold rules — the location checks
/// before a check-in and the rewards after it.
class VisitLedger extends StatelessWidget {
  const VisitLedger({required this.rows, super.key});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return ParchmentCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      // Lets the rows' ink show over the parchment.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (final (i, row) in rows.indexed) ...[if (i > 0) const GoldRule(), row],
          ],
        ),
      ),
    );
  }
}

enum CheckRowStatus { pending, active, done, failed }

/// One line in the arrival / check-in checklist: an icon disc, a label, a
/// sub-label coloured by status, and a trailing status mark.
class LocationCheckRow extends StatelessWidget {
  const LocationCheckRow({
    required this.icon,
    required this.label,
    this.sublabel,
    this.status = CheckRowStatus.pending,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? sublabel;
  final CheckRowStatus status;

  @override
  Widget build(BuildContext context) {
    final tone = switch (status) {
      CheckRowStatus.done => context.colors.success,
      CheckRowStatus.failed => context.scheme.error,
      _ => context.colors.textSecondary,
    };
    return Semantics(
      label: '$label${sublabel == null ? '' : ', $sublabel'}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            VisitIconDisc(
              icon: icon,
              color: status == CheckRowStatus.failed ? context.scheme.error : context.scheme.primary,
            ),
            const Gap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary)),
                  if (sublabel != null && sublabel!.isNotEmpty)
                    Text(sublabel!, style: context.caption.copyWith(color: tone)),
                ],
              ),
            ),
            const Gap.h(AppSpacing.sm),
            AnimatedSwitcher(duration: AppDurations.normal, child: _trailing(context)),
          ],
        ),
      ),
    );
  }

  Widget _trailing(BuildContext context) {
    switch (status) {
      case CheckRowStatus.done:
        return Icon(AppIcons.success, key: const ValueKey('done'), color: context.colors.success, size: 24, fill: 1);
      case CheckRowStatus.failed:
        return Icon(AppIcons.error, key: const ValueKey('failed'), color: context.scheme.error, size: 24, fill: 1);
      case CheckRowStatus.active:
        return SizedBox.square(
          key: const ValueKey('active'),
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: context.scheme.primary),
        );
      case CheckRowStatus.pending:
        return Icon(AppIcons.timer, key: const ValueKey('pending'), color: context.colors.textDisabled, size: 22);
    }
  }
}

/// A vertical timeline step on "Verifying Your Visit": a saffron node (filled
/// with a tick once done), the step's title and detail, and a spinner while
/// it runs.
class VerificationStep extends StatelessWidget {
  const VerificationStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    this.isLast = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final CheckRowStatus status;
  final bool isLast;

  static const double _node = 32;

  @override
  Widget build(BuildContext context) {
    final done = status == CheckRowStatus.done;
    final active = status == CheckRowStatus.active;
    final primary = context.scheme.primary;
    final idle = context.colors.textDisabled;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: AppDurations.normal,
                width: _node,
                height: _node,
                decoration: BoxDecoration(
                  // A rounded square that rounds into a disc once done (a
                  // circle shape can't animate from a radius).
                  borderRadius: BorderRadius.circular(done ? _node / 2 : AppRadius.sm),
                  color: done ? primary : (active ? primary.withValues(alpha: 0.12) : context.colors.divider),
                  border: active ? Border.all(color: primary, width: 1.5) : null,
                ),
                child: Icon(
                  done ? AppIcons.check : icon,
                  size: 18,
                  color: done ? context.scheme.onPrimary : (active ? primary : idle),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: AnimatedContainer(
                    duration: AppDurations.normal,
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                    color: done ? primary : context.colors.divider,
                  ),
                ),
            ],
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (done || active ? context.textTheme.bodyMedium?.semiBold : context.textTheme.bodyMedium)
                        ?.withColor(done || active ? context.scheme.secondary : context.colors.textSecondary),
                  ),
                  Text(subtitle, style: context.caption.copyWith(color: context.colors.textSecondary)),
                ],
              ),
            ),
          ),
          if (active)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: primary)),
            ),
        ],
      ),
    );
  }
}

/// A route's name and percent, "3 / 12 temples completed" and the animated
/// bar — the footer of the passport ledger and the head of the journey card.
class RouteProgressLine extends StatelessWidget {
  const RouteProgressLine({required this.routeName, required this.summary, required this.percent, super.key});

  final String routeName;
  final String summary;

  /// 0–100.
  final int percent;

  @override
  Widget build(BuildContext context) {
    final primary = context.scheme.primary;
    final navy = context.scheme.secondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                routeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.bold.withColor(navy),
              ),
            ),
            const Gap.h(AppSpacing.sm),
            Text('$percent%', style: context.textTheme.labelLarge?.bold.withColor(navy)),
          ],
        ),
        const Gap(AppSpacing.xxs),
        Text(summary, style: context.caption.copyWith(color: primary)),
        const Gap(AppSpacing.sm),
        AppLinearProgress(value: (percent / 100).clamp(0, 1), color: primary),
      ],
    );
  }
}

/// A round passport stamp: the temple name and date running around a double
/// ring, a temple mark and "Darshan Verified" in the middle. Struck on the
/// passport page once a visit is verified; shown faintly at check-in.
class VisitStamp extends StatelessWidget {
  const VisitStamp({required this.templeName, required this.date, required this.color, required this.size, super.key});

  final String templeName;
  final String date;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ring = '${templeName.toUpperCase()} • ${date.toUpperCase()} • ';
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _StampRingPainter(text: ring, color: color, style: context.overline),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(size * 0.24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.temple, color: color, size: size * 0.24, fill: 1),
                Text(
                  l10n.tvStampVerified.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: context.overline.copyWith(color: color, height: 1.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StampRingPainter extends CustomPainter {
  _StampRingPainter({required this.text, required this.color, required this.style});

  final String text;
  final Color color;
  final TextStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.shortestSide / 2 - 1;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.withValues(alpha: 0.85);
    canvas.drawCircle(c, outer, ring..strokeWidth = 2.5);
    canvas.drawCircle(c, outer * 0.74, ring..strokeWidth = 1.2);

    // The ring text, one glyph at a time around the band between the circles.
    final chars = text.characters.toList();
    if (chars.isEmpty) return;
    final radius = outer * 0.87;
    final step = 2 * math.pi / chars.length;
    final glyphStyle = style.copyWith(color: color, fontSize: math.min(style.fontSize ?? 10, radius * step * 1.25));
    for (var i = 0; i < chars.length; i++) {
      final angle = -math.pi / 2 + i * step;
      final painter = TextPainter(
        text: TextSpan(text: chars[i], style: glyphStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas
        ..save()
        ..translate(c.dx + radius * math.cos(angle), c.dy + radius * math.sin(angle))
        ..rotate(angle + math.pi / 2);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_StampRingPainter old) => old.text != text || old.color != color;
}
