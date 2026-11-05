import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/temple_detail.dart';
import 'temple_engagement.dart';

/// Expand/collapse long body copy (description, history).
class ExpandableText extends StatefulWidget {
  const ExpandableText({required this.text, this.trimLines = 3, super.key});

  final String text;
  final int trimLines;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, height: 1.55);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: AppDurations.normal,
          curve: AppCurves.standard,
          alignment: Alignment.topCenter,
          child: Text.rich(
            plainTextSpan(widget.text, style: style),
            maxLines: _expanded ? null : widget.trimLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        const Gap(AppSpacing.xs),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? l10n.tdReadLess : l10n.tdReadMore,
            style: context.textTheme.labelLarge?.semiBold.withColor(context.scheme.primary),
          ),
        ),
      ],
    );
  }
}

/// About + read-more.
class AboutSection extends StatelessWidget {
  const AboutSection({required this.name, required this.description, super.key});

  final String name;
  final String description;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.tdAbout} $name',
            style: context.displayText.titleLarge.withColor(context.scheme.secondary),
          ),
          const Gap(AppSpacing.sm),
          ExpandableText(text: description),
        ],
      ),
    );
  }
}

/// Deity and today's timings as rows, then history / mythology / architecture
/// as read-more cards — each only when the temple has it.
class InfoSection extends StatelessWidget {
  const InfoSection({required this.temple, super.key});

  final TempleDetail temple;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Every session today (a temple may close at midday and reopen).
    final today = temple.timings.sessionsOn(DateTime.now().weekday % 7);
    final notes = {for (final t in today) if (t.note != null) t.note!};
    final rows = <(IconData, String, String, int, String?)>[
      if (temple.deity != null) (AppIcons.pandit, l10n.tdDeity, titleCase(temple.deity!), 1, null),
      if (temple.timings.isNotEmpty)
        today.isEmpty
            ? (AppIcons.timer, l10n.tdTimings, l10n.tdClosed, 1, null)
            : (
                AppIcons.timer,
                l10n.tdTimings,
                today.map((t) => t.hours).join('\n'),
                today.length,
                notes.isEmpty ? null : notes.join('\n\n'),
              ),
    ];
    final stories = <(String, String)>[
      if (temple.history != null) (l10n.tdHistory, temple.history!),
      if (temple.mythology != null) (l10n.tdMythology, temple.mythology!),
      if (temple.architecture != null) (l10n.tdArchitecture, temple.architecture!),
    ];
    if (rows.isEmpty && stories.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.tdInfoTitle),
        if (rows.isNotEmpty)
          AppCard(
            padding: AppSpacing.allSm,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  _InfoRow(
                    icon: rows[i].$1,
                    label: rows[i].$2,
                    value: rows[i].$3,
                    maxLines: rows[i].$4,
                    note: rows[i].$5,
                  ),
                  if (i < rows.length - 1) const AppDivider(),
                ],
              ],
            ),
          ),
        for (final (i, story) in stories.indexed) ...[
          if (rows.isNotEmpty || i > 0) const Gap(AppSpacing.lg),
          _StoryCard(title: story.$1, text: story.$2),
        ],
      ],
    );
  }

  /// "SHIVA" / "SHAKTI_PEETH" → "Shiva" / "Shakti Peeth".
  static String titleCase(String s) =>
      s.split('_').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}').join(' ');
}

/// A titled block of long copy (history, mythology, architecture) with read-more.
class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.displayText.titleLarge.withColor(context.scheme.secondary)),
          const Gap(AppSpacing.sm),
          ExpandableText(text: text),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.maxLines = 1, this.note});

  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  /// Admin guidance shown under the row (e.g. darshan hours inside the
  /// opening hours, a midday break, how to book).
  final String? note;

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: _iconSize, color: context.colors.textSecondary),
              const Gap.h(AppSpacing.md),
              Text(label, style: context.textTheme.bodyMedium),
              const Gap.h(AppSpacing.md),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary),
                ),
              ),
            ],
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(left: _iconSize + AppSpacing.md, top: AppSpacing.sm),
              child: Text.rich(
                plainTextSpan(
                  note!,
                  style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary, height: 1.45),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Facilities chips.
class FacilitiesSection extends StatelessWidget {
  const FacilitiesSection({required this.facilities, super.key});

  final List<TempleFacility> facilities;

  @override
  Widget build(BuildContext context) {
    if (facilities.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.tdFacilities),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final f in facilities) AppBadge(label: f.name, icon: AppIcons.check, tone: AppBadgeTone.success),
          ],
        ),
      ],
    );
  }
}

/// My Progress — the four steps of a darshan here (visited, checked in,
/// card collected, passport stamp) as a stepper: done steps filled and
/// joined by a coloured line, the rest outlined.
class MyProgressSection extends StatelessWidget {
  const MyProgressSection({required this.status, super.key});

  final TempleMyStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = <_ProgressStep>[
      _ProgressStep(AppIcons.temple, l10n.tdVisited, status.visited, context.colors.success),
      _ProgressStep(AppIcons.verified, l10n.tdCheckIn, status.verified, context.scheme.primary),
      _ProgressStep(AppIcons.card, l10n.tdCardCollected, status.cardCollected, context.colors.gold),
      _ProgressStep(AppIcons.passport, l10n.tdStampAdded, status.visited, context.palette.accentViolet),
    ];
    final done = steps.where((s) => s.done).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.tdMyProgress),
        AppCard(
          padding: AppSpacing.allMd,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (i, step) in steps.indexed)
                    Expanded(
                      child: _StepNode(
                        step: step,
                        leftDone: i > 0 && steps[i - 1].done && step.done,
                        rightDone: i < steps.length - 1 && step.done && steps[i + 1].done,
                        first: i == 0,
                        last: i == steps.length - 1,
                      ),
                    ),
                ],
              ),
              const Gap(AppSpacing.md),
              AppLinearProgress(value: done / steps.length, height: 4, color: context.colors.success),
              const Gap(AppSpacing.xs),
              Text(
                l10n.tdStepsDone(done, steps.length),
                style: context.caption.copyWith(color: context.colors.textSecondary),
              ),
              if (status.visitCount > 0) ...[
                const Gap(AppSpacing.md),
                const AppDivider(),
                const Gap(AppSpacing.md),
                _VisitSummary(status: status),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// "Visited 3 times" with either the last visit date or — once today's
/// check-in is done — when the next one opens.
class _VisitSummary extends StatelessWidget {
  const _VisitSummary({required this.status});
  final TempleMyStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final next = status.nextCheckinAt;
    final last = status.lastVisitAt;
    final done = !status.canCheckIn;
    final color = done ? context.colors.success : context.scheme.primary;
    final String? detail;
    if (done && next != null) {
      detail = l10n.tdNextCheckIn(DateFormat.MMMd(locale).add_jm().format(next.toLocal()));
    } else if (last != null) {
      detail = l10n.tdLastVisit(DateFormat.yMMMd(locale).format(last.toLocal()));
    } else {
      detail = null;
    }
    return Row(
      children: [
        Container(
          padding: AppSpacing.allSm,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
          child: Icon(done ? AppIcons.check : AppIcons.history, size: 20, color: color),
        ),
        const Gap.h(AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.tdVisitCount(status.visitCount), style: context.textTheme.titleSmall?.semiBold),
              if (detail != null)
                Text(detail, style: context.caption.copyWith(color: done ? color : context.colors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressStep {
  const _ProgressStep(this.icon, this.label, this.done, this.color);
  final IconData icon;
  final String label;
  final bool done;
  final Color color;
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.step,
    required this.leftDone,
    required this.rightDone,
    required this.first,
    required this.last,
  });

  final _ProgressStep step;
  final bool leftDone;
  final bool rightDone;
  final bool first;
  final bool last;

  static const double _node = 44;

  @override
  Widget build(BuildContext context) {
    Widget line(bool visible, bool done) => Expanded(
          child: Container(
            height: 2,
            color: !visible ? Colors.transparent : (done ? context.colors.success : context.colors.border),
          ),
        );
    return Column(
      children: [
        SizedBox(
          height: _node,
          child: Row(
            children: [
              line(!first, leftDone),
              AnimatedContainer(
                duration: AppDurations.normal,
                width: _node,
                height: _node,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.done ? step.color : context.colors.card,
                  border: Border.all(color: step.done ? step.color : context.colors.border, width: 1.5),
                  boxShadow: step.done ? [BoxShadow(color: step.color.withValues(alpha: 0.3), blurRadius: 8)] : null,
                ),
                child: Icon(
                  step.done ? step.icon : AppIcons.lock,
                  size: 20,
                  color: step.done ? Colors.white : context.colors.textDisabled,
                  fill: 1,
                ),
              ),
              line(!last, rightDone),
            ],
          ),
        ),
        const Gap(AppSpacing.xs),
        Text(
          step.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: (step.done ? context.textTheme.labelSmall?.semiBold : context.textTheme.labelSmall)
              ?.withColor(step.done ? context.scheme.secondary : context.colors.textSecondary),
        ),
      ],
    );
  }
}

/// This temple's Sacred Card: the art in its gilt frame (stone and dimmed
/// while locked), its rarity, and the one next step — collect it with a
/// verified check-in, or open it in the collection.
class SacredCardShowcase extends StatelessWidget {
  const SacredCardShowcase({
    required this.card,
    required this.collected,
    required this.onCollect,
    required this.onView,
    super.key,
  });

  final TempleCard card;
  final bool collected;
  final VoidCallback onCollect;
  final VoidCallback onView;

  static const double _artWidth = 112;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = rarityColor(context, card.rarity);
    final gold = context.colors.gold;
    final light = context.colors.card;
    final art = card.imageUrl.isEmpty
        ? ColoredBox(color: accent.withValues(alpha: 0.2), child: Icon(AppIcons.card, color: light))
        : AppNetworkImage(url: card.imageUrl, fit: BoxFit.cover);
    return GiltFrame(
      accent: gold,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: AppSpacing.allLg,
          child: Row(
            children: [
              SizedBox(
                width: _artWidth,
                child: GiltFrame(
                  accent: accent,
                  locked: !collected,
                  aspectRatio: 3 / 4,
                  child: collected
                      ? art
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                              child: Opacity(opacity: 0.55, child: art),
                            ),
                            Center(
                              child: Container(
                                padding: AppSpacing.allSm,
                                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
                                child: Icon(AppIcons.lock, color: light, size: 22),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const Gap.h(AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.tdSacredCard.toUpperCase(), style: context.overline.copyWith(color: gold, letterSpacing: 1.4)),
                    const Gap(AppSpacing.xxs),
                    Text(
                      card.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.displayText.titleLarge.withColor(light),
                    ),
                    const Gap(AppSpacing.xs),
                    RarityChip(rarity: card.rarity, compact: true),
                    const Gap(AppSpacing.sm),
                    Row(
                      children: [
                        Icon(collected ? AppIcons.verified : AppIcons.temple, size: 14, color: collected ? context.colors.success : gold),
                        const Gap.h(AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            collected ? l10n.tdCardInCollection : l10n.tdCardHowToCollect,
                            style: context.caption.copyWith(color: light.withValues(alpha: 0.8)),
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.md),
                    collected
                        ? AppButton.outlined(
                            label: l10n.tdViewCard,
                            icon: AppIcons.card,
                            size: AppButtonSize.small,
                            onPressed: onView,
                          )
                        : AppButton.primary(
                            label: l10n.tdCollectCard,
                            icon: AppIcons.card,
                            size: AppButtonSize.small,
                            onPressed: onCollect,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Darshan Today — the first thing under the hero: open or closed right
/// now with a countdown to the next change, today's hours on a 24-hour bar,
/// and quick facts (open days, photography, rating).
class DarshanTodaySection extends StatelessWidget {
  const DarshanTodaySection({required this.temple, required this.now, super.key});

  final TempleDetail temple;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final timings = temple.timings;
    final chips = _chips(context, l10n);
    if (timings.isEmpty && chips.isEmpty) return const SizedBox.shrink();

    final day = now.weekday % 7;
    final today = timings.sessionsOn(day);
    final status = timings.statusAt(now);
    final open = status?.open ?? false;
    final color = open ? context.colors.success : context.scheme.error;
    final title = open ? l10n.tdOpenNow : (today.isEmpty ? l10n.tdClosedToday : l10n.tdClosedNow);
    final spans = timings.daySpans(day);

    return ParchmentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tdDarshanToday.toUpperCase(), style: context.overline.copyWith(color: context.colors.gold)),
          if (timings.isNotEmpty) ...[
            const Gap(AppSpacing.sm),
            Row(
              children: [
                IllustratedIcon(fallbackIcon: AppIcons.timer, color: color, size: 40),
                const Gap.h(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.textTheme.titleMedium?.bold.withColor(color)),
                      if (_changeLine(l10n) case final line?)
                        Text(line, style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary)),
                    ],
                  ),
                ),
                if (today.isNotEmpty) ...[
                  const Gap.h(AppSpacing.sm),
                  Text(
                    today.map((t) => t.hours).join('\n'),
                    textAlign: TextAlign.right,
                    style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary),
                  ),
                ],
              ],
            ),
            if (spans.isNotEmpty) ...[
              const Gap(AppSpacing.md),
              _DayBar(spans: spans, now: (now.hour * 60 + now.minute) / (24 * 60), color: context.colors.success),
            ],
          ],
          if (chips.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: chips),
          ],
        ],
      ),
    );
  }

  /// "Closes at 21:30 · in 3 h 10 min", "Opens at 16:00 · in 40 min",
  /// "Opens tomorrow at 04:30".
  String? _changeLine(AppLocalizations l10n) {
    final change = temple.timings.nextChange(now);
    if (change == null) return null;
    if (change.tomorrow) return l10n.tdOpensTomorrowAt(change.at);
    final at = change.open ? l10n.tdClosesAt(change.at) : l10n.tdOpensAt(change.at);
    final mins = change.minutes!;
    final wait = mins >= 60 ? l10n.tdInHoursMinutes(mins ~/ 60, mins % 60) : l10n.tdInMinutes(mins);
    return '$at · $wait';
  }

  List<Widget> _chips(BuildContext context, AppLocalizations l10n) {
    final closed = temple.timings.closedDays;
    final weekday = DateFormat.E(Localizations.localeOf(context).toString());
    // 1 Jan 2023 was a Sunday, so day d (0 = Sunday) is 1 + d January.
    String dayName(int d) => weekday.format(DateTime(2023, 1, 1 + d));
    final photo = VisitorInfoSection.photographyLabel(l10n, temple.visitorInfo.photographyPolicy);
    return [
      if (temple.timings.isNotEmpty)
        closed.isEmpty
            ? AppBadge(label: l10n.tdOpenAllWeek, icon: AppIcons.calendar, tone: AppBadgeTone.success)
            : AppBadge(
                label: l10n.tdClosedOnDays(closed.map(dayName).join(', ')),
                icon: AppIcons.calendar,
                tone: AppBadgeTone.warning,
              ),
      if (photo != null)
        AppBadge(
          label: '${l10n.tdPhotography}: $photo',
          icon: AppIcons.camera,
          tone: switch (temple.visitorInfo.photographyPolicy) {
            'ALLOWED' => AppBadgeTone.success,
            'RESTRICTED' => AppBadgeTone.warning,
            _ => AppBadgeTone.error,
          },
        ),
      if (temple.ratingCount > 0)
        AppBadge(
          label: '${temple.ratingAverage.toStringAsFixed(1)} · ${l10n.tdReviewCount(temple.ratingCount)}',
          icon: AppIcons.star,
          tone: AppBadgeTone.gold,
        ),
    ];
  }
}

/// Today on a 24-hour track: open spans filled, a dot at the current time,
/// and 6-hour ticks underneath.
class _DayBar extends StatelessWidget {
  const _DayBar({required this.spans, required this.now, required this.color});

  final List<(double, double)> spans;
  final double now;
  final Color color;

  static const _ticks = ['00:00', '06:00', '12:00', '18:00', '24:00'];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        children: [
          SizedBox(
            height: AppSpacing.md,
            width: double.infinity,
            child: CustomPaint(
              painter: _DayBarPainter(
                spans: spans,
                now: now,
                track: context.scheme.outlineVariant,
                fill: color,
                marker: context.scheme.primary,
                ring: context.colors.card,
              ),
            ),
          ),
          const Gap(AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final t in _ticks) Text(t, style: context.caption.copyWith(color: context.colors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayBarPainter extends CustomPainter {
  _DayBarPainter({
    required this.spans,
    required this.now,
    required this.track,
    required this.fill,
    required this.marker,
    required this.ring,
  });

  final List<(double, double)> spans;
  final double now;
  final Color track;
  final Color fill;
  final Color marker;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final barHeight = size.height / 2;
    final top = (size.height - barHeight) / 2;
    final radius = Radius.circular(barHeight / 2);
    canvas.drawRRect(
      RRect.fromLTRBR(0, top, size.width, top + barHeight, radius),
      Paint()..color = track,
    );
    final paint = Paint()..color = fill;
    for (final (start, end) in spans) {
      canvas.drawRRect(
        RRect.fromLTRBR(start * size.width, top, end * size.width, top + barHeight, radius),
        paint,
      );
    }
    final centre = Offset(now.clamp(0, 1) * size.width, size.height / 2);
    canvas
      ..drawCircle(centre, size.height / 2, Paint()..color = ring)
      ..drawCircle(centre, size.height / 2 - AppSpacing.xxs, Paint()..color = marker);
  }

  @override
  bool shouldRepaint(_DayBarPainter old) =>
      old.now != now || old.spans != spans || old.fill != fill || old.track != track;
}

/// Route integration + user progress.
class RouteIntegrationSection extends StatelessWidget {
  const RouteIntegrationSection({required this.routes, required this.progress, required this.onOpen, super.key});

  final List<TempleRouteLink> routes;
  final List<MyRouteProgress> progress;
  final ValueChanged<String> onOpen; // route slug

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final progressBySlug = {for (final p in progress) p.slug: p};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.tdRouteIntegration),
        for (final r in routes) ...[
          _RouteCard(route: r, progress: progressBySlug[r.slug], onTap: () => onOpen(r.slug)),
          const Gap(AppSpacing.md),
        ],
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.route, required this.progress, required this.onTap});

  final TempleRouteLink route;
  final MyRouteProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percent = progress?.percent ?? 0;
    final completed = progress?.completedTemples ?? 0;
    final total = progress?.templeCount ?? route.templeCount;
    final done = percent >= 100;
    final accent = done ? context.colors.success : context.scheme.primary;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IllustratedIcon(fallbackIcon: done ? AppIcons.verified : AppIcons.route, color: accent, size: 48),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary),
                ),
                const Gap(AppSpacing.xxs),
                Text(
                  '$completed / $total ${l10n.tdCompleted}',
                  style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                ),
                const Gap(AppSpacing.sm),
                AppLinearProgress(value: (percent / 100).clamp(0.0, 1.0), height: 6, color: accent),
              ],
            ),
          ),
          const Gap.h(AppSpacing.sm),
          Text('$percent%', style: context.textTheme.labelLarge?.bold.withColor(accent)),
        ],
      ),
    );
  }
}

/// Gallery grid with a "+N" overflow tile.
class GallerySection extends StatelessWidget {
  const GallerySection({required this.images, required this.onOpen, super.key});

  final List<TempleImage> images;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final shown = images.take(4).toList();
    final extra = images.length - shown.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.tdGallery, onViewAll: () => onOpen(0), viewAllLabel: l10n.commonViewAll),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: shown.length,
            separatorBuilder: (_, _) => const Gap.h(AppSpacing.sm),
            itemBuilder: (context, i) {
              final isLast = i == shown.length - 1 && extra > 0;
              return GestureDetector(
                onTap: () => onOpen(i),
                child: Stack(
                  children: [
                    Hero(
                      tag: 'temple-gallery-$i',
                      child: AppNetworkImage(
                        url: shown[i].url,
                        width: 90,
                        height: 90,
                        borderRadius: AppRadius.mdAll,
                        placeholderIcon: AppIcons.temple,
                      ),
                    ),
                    if (isLast)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: AppRadius.mdAll,
                          ),
                          child: Center(
                            child: Text(
                              '+$extra',
                              style: context.textTheme.titleMedium?.bold.withColor(Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Nearby temples — horizontal cards.
class NearbyTemplesSection extends StatelessWidget {
  const NearbyTemplesSection({required this.nearby, required this.onOpen, this.title, this.showHeader = true, super.key});

  final List<NearbyTempleRef> nearby;
  final ValueChanged<String> onOpen; // slug
  /// Header text; defaults to "Nearby Temples".
  final String? title;
  /// False when a parent (e.g. an expandable row) already labels the strip.
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    if (nearby.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) SectionHeader(title: title ?? l10n.tdNearbyTemples),
        SizedBox(
          height: 228,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            itemCount: nearby.length,
            separatorBuilder: (_, _) => const Gap.h(AppSpacing.md),
            itemBuilder: (context, i) {
              final n = nearby[i];
              return SizedBox(
                width: 160,
                child: TempleCardBase(
                  dense: true,
                  imageHeight: 104,
                  name: n.name,
                  location: n.city ?? '',
                  imageUrl: n.imageUrl,
                  chip: PhotoPill(label: n.formattedDistance, icon: AppIcons.nearby),
                  footer: RatingBadge(rating: n.ratingAverage, count: n.ratingCount),
                  onTap: () => onOpen(n.slug),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
