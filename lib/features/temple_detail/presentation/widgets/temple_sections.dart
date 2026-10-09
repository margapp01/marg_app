import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/temple_detail.dart';

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
          child: Text(
            widget.text,
            style: style,
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

/// Live Temple Intelligence card: occupancy / capacity / peak + best-time.
class IntelligenceCard extends StatelessWidget {
  const IntelligenceCard({
    required this.crowd,
    required this.bestTimeWindow,
    required this.peakWindow,
    super.key,
  });

  final CrowdInfo crowd;
  final String? bestTimeWindow;
  final String? peakWindow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meta = crowdMeta(context, l10n, crowd.crowdLevel);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.tdIntelligenceTitle,
                  style: context.textTheme.titleSmall?.bold.withColor(context.scheme.secondary),
                ),
              ),
              _LiveDot(),
              const Gap.h(AppSpacing.xs),
              Text(
                l10n.tdUpdatedLive,
                style: context.textTheme.labelSmall?.copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
          const Gap(AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Gauge(
                  label: l10n.tdOccupancy,
                  value: '${crowd.occupancyPercent}%',
                  sub: meta.label,
                  color: meta.color,
                ),
              ),
              Expanded(
                child: _Gauge(
                  label: l10n.tdCapacity,
                  value: crowd.capacity > 0 ? '${crowd.capacity}' : '—',
                  sub: l10n.tdPeople,
                  color: context.scheme.primary,
                ),
              ),
              if (peakWindow != null)
                Expanded(
                  child: _Gauge(
                    label: l10n.tdPeakHours,
                    value: peakWindow!,
                    sub: '',
                    color: context.scheme.secondary,
                    small: true,
                  ),
                ),
            ],
          ),
          if (bestTimeWindow != null) ...[
            const Gap(AppSpacing.lg),
            Container(
              padding: AppSpacing.allMd,
              decoration: BoxDecoration(
                color: context.scheme.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.card,
              ),
              child: Row(
                children: [
                  Icon(AppIcons.check, size: 18, color: context.scheme.primary),
                  const Gap.h(AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${l10n.tdBestTimeToday}: $bestTimeWindow',
                      style: context.textTheme.labelLarge?.copyWith(color: context.scheme.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: context.colors.success, shape: BoxShape.circle),
    );
  }
}

class _Gauge extends StatelessWidget {
  const _Gauge({required this.label, required this.value, required this.sub, required this.color, this.small = false});

  final String label;
  final String value;
  final String sub;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: context.textTheme.labelSmall?.copyWith(color: context.colors.textSecondary)),
        const Gap(AppSpacing.xs),
        Text(
          value,
          textAlign: TextAlign.center,
          // Time windows ("5:00 AM – 10:00 AM") wrap rather than truncate.
          maxLines: small ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: (small ? context.textTheme.labelLarge : context.displayText.titleLarge)?.bold.withColor(color),
        ),
        if (sub.isNotEmpty)
          Text(sub, style: context.textTheme.labelSmall?.copyWith(color: context.colors.textSecondary)),
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

/// Deity / architecture / timings / history rows (only present fields).
class InfoSection extends StatelessWidget {
  const InfoSection({required this.temple, super.key});

  final TempleDetail temple;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = <(IconData, String, String)>[
      if (temple.deity != null) (AppIcons.pandit, l10n.tdDeity, titleCase(temple.deity!)),
      if (temple.timings.isNotEmpty) (AppIcons.timer, l10n.tdTimings, _timingLabel(temple.timings)),
      if (temple.architecture != null) (AppIcons.temple, l10n.tdArchitecture, temple.architecture!),
    ];
    if (rows.isEmpty && temple.history == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.tdInfoTitle),
        AppCard(
          padding: AppSpacing.allSm,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                _InfoRow(icon: rows[i].$1, label: rows[i].$2, value: rows[i].$3),
                if (i < rows.length - 1) const AppDivider(),
              ],
            ],
          ),
        ),
        if (temple.history != null) ...[
          const Gap(AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tdHistory, style: context.displayText.titleLarge.withColor(context.scheme.secondary)),
                const Gap(AppSpacing.sm),
                ExpandableText(text: temple.history!),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static String _timingLabel(List<TempleTiming> timings) {
    final today = DateTime.now().weekday % 7; // Dart Mon=1..Sun=7 → 0=Sun
    final match = timings.where((t) => t.dayOfWeek == today);
    final t = match.isNotEmpty ? match.first : timings.first;
    return '${t.openTime} – ${t.closeTime}';
  }

  /// "SHIVA" / "SHAKTI_PEETH" → "Shiva" / "Shakti Peeth".
  static String titleCase(String s) =>
      s.split('_').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}').join(' ');
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allSm,
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.colors.textSecondary),
          const Gap.h(AppSpacing.md),
          Text(label, style: context.textTheme.bodyMedium),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary),
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

/// The temple at a glance on parchment: open or closed today with its hours,
/// the live crowd, the wait, and the rating — divided by gold rules.
class TempleGlance extends StatelessWidget {
  const TempleGlance({required this.cells, super.key});

  final List<GlanceCell> cells;

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) return const SizedBox.shrink();
    return ParchmentCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, cell) in cells.indexed) ...[
              if (i > 0) const GoldRule(vertical: true),
              Expanded(child: cell),
            ],
          ],
        ),
      ),
    );
  }
}

/// One fact in a [TempleGlance]: a tinted icon, the value, a small label.
class GlanceCell extends StatelessWidget {
  const GlanceCell({required this.icon, required this.value, required this.label, required this.color, super.key});

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: Column(
        children: [
          IllustratedIcon(fallbackIcon: icon, color: color, size: 32),
          const Gap(AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textTheme.labelLarge?.bold.withColor(color),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.caption.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
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
  const NearbyTemplesSection({required this.nearby, required this.onOpen, super.key});

  final List<NearbyTempleRef> nearby;
  final ValueChanged<String> onOpen; // slug

  @override
  Widget build(BuildContext context) {
    if (nearby.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.tdNearbyTemples),
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
