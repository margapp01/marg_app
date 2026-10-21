import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/home_dashboard.dart';

/// Sacred Cards — the devotee's most recently unlocked card art.
class SacredCardsRail extends StatelessWidget {
  const SacredCardsRail({required this.cards, required this.onViewAll, required this.onOpen, super.key});

  final List<HomeCard> cards;
  final VoidCallback onViewAll;
  final ValueChanged<HomeCard> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.screenH,
          child: SectionHeader(title: l10n.homeSectionCards, onViewAll: onViewAll, viewAllLabel: l10n.commonViewAll),
        ),
        if (cards.isEmpty)
          Padding(
            padding: AppSpacing.screenH,
            child: AppCard(
              gradient: AppGradients.night,
              onTap: onViewAll,
              child: Row(
                children: [
                  IllustratedIcon(fallbackIcon: AppIcons.card, color: context.colors.gold, background: Colors.white12, size: 44),
                  const Gap.h(AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.homeCardsEmpty,
                      style: context.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 196,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screenH,
              itemCount: cards.length,
              separatorBuilder: (_, _) => const Gap.h(AppSpacing.md),
              itemBuilder: (context, i) => _CardArt(card: cards[i], onTap: () => onOpen(cards[i])),
            ),
          ),
      ],
    );
  }
}

class _CardArt extends StatelessWidget {
  const _CardArt({required this.card, required this.onTap});

  final HomeCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = rarityColor(context, card.rarity);
    return SizedBox(
      width: 100,
      child: Semantics(
        button: true,
        label: '${card.title}, ${rarityLabel(l10n, card.rarity)}',
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: color.withValues(alpha: 0.7), width: 1.5),
                  boxShadow: AppShadows.sm,
                  gradient: AppGradients.night,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (card.imageUrl != null)
                      AppNetworkImage(url: card.imageUrl!, placeholderIcon: AppIcons.card)
                    else
                      Icon(AppIcons.temple, color: context.colors.gold, size: 40),
                    Positioned(
                      top: AppSpacing.xs,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1),
                          decoration: BoxDecoration(color: color, borderRadius: AppRadius.fullAll),
                          child: Text(
                            rarityLabel(l10n, card.rarity).toUpperCase(),
                            style: context.overline.copyWith(color: Colors.white, letterSpacing: 0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.sm),
              Text(
                card.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.semiBold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Upcoming Festivals — image, name, deity and a date tile.
class FestivalsSection extends StatelessWidget {
  const FestivalsSection({required this.festivals, required this.onViewAll, required this.onOpen, super.key});

  final List<HomeFestival> festivals;
  final VoidCallback onViewAll;
  final ValueChanged<HomeFestival> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.homeSectionFestivals, onViewAll: onViewAll, viewAllLabel: l10n.commonViewAll),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              for (var i = 0; i < festivals.length; i++) ...[
                if (i > 0) const AppDivider(),
                _FestivalRow(festival: festivals[i], onTap: () => onOpen(festivals[i])),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FestivalRow extends StatelessWidget {
  const _FestivalRow({required this.festival, required this.onTap});

  final HomeFestival festival;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = festival.startDate;
    final saffron = context.palette.accentSaffron;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            if (festival.imageUrl != null)
              ClipOval(child: AppNetworkImage(url: festival.imageUrl!, width: 52, height: 52, placeholderIcon: AppIcons.festival))
            else
              IllustratedIcon(fallbackIcon: AppIcons.festival, color: saffron, size: 52),
            const Gap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(festival.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.titleSmall?.semiBold),
                  if (festival.deity != null)
                    Text(festival.deity!, style: context.caption.copyWith(color: context.colors.textSecondary)),
                ],
              ),
            ),
            if (date != null)
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: context.palette.tilePeach,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: saffron.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    Text(DateFormat('dd').format(date), style: context.textTheme.titleMedium?.bold.withColor(saffron)),
                    Text(DateFormat('MMM').format(date), style: context.textTheme.labelSmall?.semiBold.withColor(saffron)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Recent Activity — visits, cards, achievements, routes and referrals on
/// the journey rail (as in the Passport timeline and the Activity Feed), each
/// with when it happened and the points it earned.
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({required this.activities, required this.onViewAll, required this.onOpen, super.key});

  final List<HomeActivity> activities;
  final VoidCallback onViewAll;
  final ValueChanged<HomeActivity> onOpen;

  /// (icon, colour) for a backend activity type.
  static (IconData, Color) _visual(BuildContext context, String type) {
    final p = context.palette;
    return switch (type) {
      'VISIT' => (AppIcons.temple, p.accentSaffron),
      'CARD' => (AppIcons.card, p.accentViolet),
      'ACHIEVEMENT' => (AppIcons.achievement, context.colors.gold),
      'ROUTE' => (AppIcons.route, p.accentBlue),
      'REFERRAL' => (AppIcons.referral, p.accentRose),
      _ => (AppIcons.temple, p.accentSaffron),
    };
  }

  static String? _when(AppLocalizations l10n, DateTime? at) {
    if (at == null) return null;
    final local = at.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final time = formatHour(local.hour, minute: local.minute);
    if (day == today) return l10n.homeToday(time);
    if (day == today.subtract(const Duration(days: 1))) return l10n.homeYesterday(time);
    return DateFormat('d MMM yyyy').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.homeSectionActivity, onViewAll: onViewAll, viewAllLabel: l10n.commonViewAll),
        for (final (i, a) in activities.indexed)
          Builder(
            builder: (context) {
              final (icon, color) = _visual(context, a.type);
              final points = a.points;
              return JourneyRailTile(
                icon: icon,
                color: color,
                title: a.title,
                titleMaxLines: 2,
                imageUrl: a.imageUrl,
                caption: _when(l10n, a.createdAt),
                captionIcon: AppIcons.timer,
                trailing: points != null && points > 0
                    ? AppBadge(
                        label: l10n.homePointsEarned(points),
                        tone: AppBadgeTone.gold,
                        icon: AppIcons.points,
                        solid: true,
                      )
                    : null,
                isLast: i == activities.length - 1,
                onTap: () => onOpen(a),
              ).fadeIn(delay: AppDurations.stagger * i);
            },
          ),
      ],
    );
  }
}
