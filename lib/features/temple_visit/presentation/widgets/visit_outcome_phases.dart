import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:latlong2/latlong.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/design_system.dart';
import '../../../cards/domain/entities/sacred_card.dart';
import '../../../cards/presentation/widgets/card_reveal.dart';
import '../../../cards/presentation/widgets/card_widgets.dart';
import '../../../routes/domain/entities/route_detail_bundle.dart';
import '../../../routes/domain/entities/yatra_route.dart';
import '../../../routes/presentation/controllers/routes_controllers.dart';
import '../../domain/entities/checkin_failure.dart';
import '../../domain/entities/checkin_result.dart';
import '../controllers/temple_visit_controller.dart';
import 'visit_components.dart';

// ─────────────────────────── Visit Verified ───────────────────────────

/// The visit's summary — and its last stop. The temple in a gold ring with
/// the verified seal, the darshan record on parchment, and each reward of the
/// visit as a ledger row. The card reveal, passport stamp, achievement and
/// next temple open on a tap and are all optional: Done ends the visit here.
class SuccessPhase extends StatelessWidget {
  const SuccessPhase({required this.state, required this.onOpen, required this.onDone, super.key});

  final TempleVisitState state;

  /// Opens one reward's screen (a [TempleVisitPhase.opensFromSummary] phase).
  final ValueChanged<TempleVisitPhase> onOpen;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = state.result;
    final rewards = result?.rewards;
    final card = rewards?.card;
    final achievements = rewards?.achievements ?? const <VisitRewardAchievement>[];
    final points = achievements.fold(0, (sum, a) => sum + a.points);
    final route = state.routeProgress;
    final temple = state.temple;
    final time = DateFormat.jm(Localizations.localeOf(context).toLanguageTag()).format(DateTime.now());
    // A new card is the visit's headline reward — offer its reveal first.
    final revealFirst = (rewards?.hasNewCard ?? false) && !state.cardSeen;

    final rows = <Widget>[
      // A repeat visit returns the card already owned — say so instead of
      // celebrating an unlock that didn't happen.
      if (card != null)
        VisitRewardRow(
          leading: _MiniCard(card: card),
          title: card.unlocked ? l10n.tvCardUnlocked : l10n.tvCardInCollection,
          detail: rarityLabel(l10n, card.rarity),
          detailColor: rarityColor(context, card.rarity),
          onTap: () => onOpen(TempleVisitPhase.cardUnlock),
        ),
      if (route != null)
        VisitRewardRow(
          leading: IllustratedIcon(fallbackIcon: AppIcons.passport, color: context.scheme.primary),
          title: l10n.tvPassportUpdated,
          detail: l10n.tvTemplesOfTotal(route.completedTemples, route.totalTemples),
          detailColor: context.scheme.primary,
          onTap: () => onOpen(TempleVisitPhase.passportUpdate),
        ),
      if (achievements.isNotEmpty)
        VisitRewardRow(
          leading: IllustratedIcon(
            asset: BrandAssets.illustrationMedal,
            fallbackIcon: AppIcons.achievement,
            color: context.colors.gold,
          ),
          title: l10n.tvAchievementBarTitle,
          detail: [achievements.first.name, if (points > 0) l10n.tvPointsEarned(points)].join(' · '),
          detailColor: context.palette.accentViolet,
          onTap: () => onOpen(TempleVisitPhase.achievement),
        ),
      if (route != null)
        VisitRewardRow(
          leading: IllustratedIcon(fallbackIcon: AppIcons.route, color: context.palette.accentBlue),
          title: l10n.tvJourneyContinuesTitle,
          detail: route.isComplete
              ? l10n.tvRouteCompleted(route.name)
              : (route.nextTemple == null ? route.name : l10n.tvNextTempleNamed(route.nextTemple!.name)),
          detailColor: context.palette.accentBlue,
          onTap: () => onOpen(TempleVisitPhase.continueJourney),
        ),
    ];

    return Stack(
      children: [
        VisitPhaseBody(
          content: [
            _VerifiedHero(imageUrl: temple?.imageUrl, name: temple?.name ?? ''),
            Text(
              l10n.tvVerifiedTitle,
              textAlign: TextAlign.center,
              style: context.displayText.headlineMedium.withColor(context.scheme.secondary),
            ).fadeIn(delay: AppDurations.slow),
            const Gap(AppSpacing.xxs),
            Text(
              deityGreeting(l10n, temple?.deity),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.primary),
            ).fadeIn(delay: AppDurations.slow + AppDurations.stagger * 2),
            const Gap(AppSpacing.lg),
            _DarshanRecord(
              name: temple?.name ?? '',
              location: temple?.location,
              time: l10n.tvTodayAt(time),
              trustScore: result?.trustScore ?? 0,
            ).fadeIn(delay: AppDurations.slow + AppDurations.stagger * 3),
            if (rows.isNotEmpty) ...[
              const Gap(AppSpacing.lg),
              GoldRuleHeader(label: l10n.tvFromThisVisit),
              const Gap(AppSpacing.sm),
              VisitLedger(rows: rows).fadeIn(delay: AppDurations.slow + AppDurations.stagger * 4),
            ],
          ],
          actions: [
            if (revealFirst) ...[
              AppButton.primary(
                label: l10n.tvRevealCard,
                icon: AppIcons.card,
                onPressed: () => onOpen(TempleVisitPhase.cardUnlock),
              ),
              const Gap(AppSpacing.sm),
              AppButton.ghost(label: l10n.tvDone, onPressed: onDone),
            ] else
              AppButton.primary(label: l10n.tvDone, icon: AppIcons.check, onPressed: onDone),
          ],
        ),
        const Positioned.fill(child: ConfettiOverlay()),
      ],
    );
  }
}

/// The temple in a gold ring over the skyline line-art, sealed with a drawn
/// green tick amid a burst of gold dust.
class _VerifiedHero extends StatelessWidget {
  const _VerifiedHero({required this.imageUrl, required this.name});

  final String? imageUrl;
  final String name;

  static const double _height = 196;
  static const double _radius = 60;
  static const double _seal = 40;
  static const double _skyline = 104;

  @override
  Widget build(BuildContext context) {
    final ring = GoldRingAvatar.diameterFor(_radius);
    // The seal paints in a box wider than its disc (room for the ripple);
    // centre the disc on the ring's lower-right edge.
    final sealBox = _seal * DrawnCheckSeal.boxFactor;
    final sealAt = ring / 2 * (1 + math.sqrt1_2) - sealBox / 2;
    return SizedBox(
      height: _height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _skyline,
            child: ExcludeSemantics(
              child: Image.asset(
                BrandAssets.skylineLineArt,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                opacity: const AlwaysStoppedAnimation(0.22),
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          SparkleField(color: context.colors.gold, count: 20, burst: true),
          SizedBox.square(
            dimension: ring,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GoldRingAvatar(imageUrl: imageUrl, name: name, radius: _radius).scaleIn(),
                Positioned(
                  left: sealAt,
                  top: sealAt,
                  child: SizedBox.square(
                    dimension: sealBox,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: _seal + AppSpacing.sm,
                          height: _seal + AppSpacing.sm,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: context.scheme.surface),
                        ),
                        DrawnCheckSeal(color: context.colors.success, size: _seal),
                      ],
                    ),
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

/// The visit's record on parchment — "Darshan Verified", the temple and its
/// place beside the MARG mark, then when it happened and the trust score.
class _DarshanRecord extends StatelessWidget {
  const _DarshanRecord({required this.name, required this.time, required this.trustScore, this.location});

  final String name;
  final String? location;
  final String time;
  final int trustScore;

  static const double _mark = 56;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = this.location;
    return ParchmentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tvStampVerified.toUpperCase(),
                      style: context.overline.copyWith(color: context.colors.gold, letterSpacing: 1.4),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.displayText.titleLarge.withColor(context.scheme.secondary),
                    ),
                    if (location != null && location.isNotEmpty) ...[
                      const Gap(AppSpacing.xxs),
                      Text(location, style: context.caption.copyWith(color: context.colors.textSecondary)),
                    ],
                  ],
                ),
              ),
              const Gap.h(AppSpacing.md),
              Image.asset(
                BrandAssets.logoMark,
                height: _mark,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          const GoldRule(),
          const Gap(AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _RecordFact(icon: AppIcons.calendar, text: time),
              _RecordFact(icon: AppIcons.trustScore, text: '${l10n.tvTrustScore} $trustScore'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordFact extends StatelessWidget {
  const _RecordFact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.colors.gold, fill: 1),
        const Gap.h(AppSpacing.xxs),
        Text(text, style: context.caption.semiBold.copyWith(color: context.scheme.secondary)),
      ],
    );
  }
}

/// The visit's card as a small gold-edged thumbnail, glowing in its rarity.
class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.card});

  final VisitRewardCard card;

  static const double _height = 44;

  @override
  Widget build(BuildContext context) {
    final accent = rarityColor(context, card.rarity);
    final blank = ColoredBox(color: accent.withValues(alpha: 0.15));
    return Container(
      height: _height,
      width: _height * SacredCardFace.aspect,
      decoration: BoxDecoration(
        borderRadius: AppRadius.smAll,
        border: Border.all(color: context.colors.gold, width: 1.5),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xsAll,
        child: card.imageUrl.isEmpty ? blank : AppNetworkImage(url: card.imageUrl, fit: BoxFit.cover, fallback: blank),
      ),
    );
  }
}

/// "Jai Bholenath!" for a Shiva temple, "Jai Mata Di!" for Devi… — the
/// greeting that closes a verified visit.
String deityGreeting(AppLocalizations l10n, String? deity) => switch (deity?.toUpperCase()) {
  'SHIVA' => l10n.tvGreetShiva,
  'VISHNU' => l10n.tvGreetVishnu,
  'DEVI' => l10n.tvGreetDevi,
  'GANESHA' => l10n.tvGreetGanesha,
  'HANUMAN' => l10n.tvGreetHanuman,
  'SURYA' => l10n.tvGreetSurya,
  _ => l10n.tvGreetOther,
};

// ─────────────────────────── Card Unlocked ───────────────────────────

/// The card moment, on the night sky of the collectibles: the card rises
/// face-down, flips in a flash of light to reveal itself, then floats amid
/// gold dust while the rarity banner, confetti and actions arrive. Done ends
/// the visit; Back returns to the summary. Reopened, the face shows at once.
class CardUnlockPhase extends StatefulWidget {
  const CardUnlockPhase({
    required this.card,
    required this.onBack,
    required this.onViewCollection,
    required this.onDone,
    this.animate = true,
    super.key,
  });

  final VisitRewardCard card;
  final VoidCallback onBack;
  final VoidCallback onViewCollection;
  final VoidCallback onDone;
  final bool animate;

  @override
  State<CardUnlockPhase> createState() => _CardUnlockPhaseState();
}

class _CardUnlockPhaseState extends State<CardUnlockPhase> {
  final _shareKey = GlobalKey();
  bool _revealed = false;
  bool _sharing = false;

  /// Share of the free height the card may take, and its width cap.
  static const double _heightShare = 0.78;
  static const double _maxWidth = 300;
  static const double _float = 6;

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _sharing = true);
    try {
      await shareBoundaryImage(
        _shareKey,
        text: l10n.tvShareCardText(widget.card.title),
        fileName: 'marg-card-${widget.card.id}.png',
      );
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.tvShareFailed);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final card = widget.card;
    final accent = rarityColor(context, card.rarity);
    final gold = context.colors.gold;
    final light = context.colors.card;
    final face = SacredCardFace(
      card: SacredCard(id: card.id, title: card.title, imageUrl: card.imageUrl, rarity: card.rarity, owned: true),
      size: SacredCardSize.hero,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.night)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.1),
                radius: 0.9,
                colors: [accent.withValues(alpha: 0.4), accent.withValues(alpha: 0)],
              ),
            ),
          ),
          SparkleField(color: gold, count: 28),
          if (_revealed && widget.animate) SparkleField(color: gold, count: 22, burst: true, seed: 11),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: kToolbarHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: BackButton(color: light, onPressed: widget.onBack),
                      ),
                      Text(
                        card.unlocked ? l10n.tvCardTitle : l10n.tvCardInCollection,
                        style: context.textTheme.titleMedium?.semiBold.withColor(light),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.sm),
                _Arrive(
                  shown: _revealed,
                  child: RarityRibbon(rarity: card.rarity),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = math.min(
                        _maxWidth,
                        math.min(
                          constraints.maxWidth * 0.7,
                          constraints.maxHeight * _heightShare * SacredCardFace.aspect,
                        ),
                      );
                      return Center(
                        child: GlowPulse(
                          color: accent,
                          radius: width * 0.85,
                          child: FloatBob(
                            amplitude: _revealed ? _float : 0,
                            child: SizedBox(
                              width: width,
                              child: RepaintBoundary(
                                key: _shareKey,
                                child: CardReveal(
                                  front: face,
                                  animate: widget.animate,
                                  onRevealed: () => setState(() => _revealed = true),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _Arrive(
                  shown: _revealed,
                  child: Text(
                    card.unlocked ? l10n.tvCardUnlockedBody : card.title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium?.semiBold.withColor(light),
                  ),
                ),
                Padding(
                  padding: AppSpacing.screenAll,
                  child: _Arrive(
                    shown: _revealed,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppButton.secondary(
                                label: l10n.tvViewCollection,
                                icon: AppIcons.card,
                                onPressed: widget.onViewCollection,
                              ),
                            ),
                            const Gap.h(AppSpacing.sm),
                            Expanded(
                              child: AppButton.secondary(
                                label: l10n.tvShareCard,
                                icon: AppIcons.share,
                                busy: _sharing,
                                onPressed: _share,
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.sm),
                        AppButton.primary(label: l10n.tvDone, icon: AppIcons.check, onPressed: widget.onDone),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_revealed && widget.animate) const Positioned.fill(child: ConfettiOverlay(particleCount: 40)),
        ],
      ),
    );
  }
}

/// Fades and lifts [child] in once [shown]; untappable until then.
class _Arrive extends StatelessWidget {
  const _Arrive({required this.shown, required this.child});

  final bool shown;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !shown,
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: AppDurations.slow,
        curve: AppCurves.enter,
        child: AnimatedSlide(
          offset: shown ? Offset.zero : const Offset(0, 0.3),
          duration: AppDurations.slow,
          curve: AppCurves.enter,
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────── Passport Updated ───────────────────────────

/// Today's stamp struck on a passport page, then the route's numbers on a
/// parchment ledger with its progress underneath. Opened from the summary.
class PassportUpdatePhase extends StatelessWidget {
  const PassportUpdatePhase({required this.state, required this.onViewPassport, super.key});

  final TempleVisitState state;
  final VoidCallback onViewPassport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = state.routeProgress;
    final temple = state.temple;

    return VisitPhaseBody(
      content: [
        Text(l10n.tvPassportTitle, style: context.displayText.titleLarge.withColor(context.scheme.secondary)),
        const Gap(AppSpacing.md),
        _PassportPage(templeName: temple?.name ?? ''),
        if (route != null) ...[
          const Gap(AppSpacing.lg),
          GoldRuleHeader(label: l10n.tvRouteProgress),
          const Gap(AppSpacing.sm),
          StatLedger(
            stats: [
              LedgerStat(
                icon: AppIcons.temple,
                color: context.palette.accentSaffron,
                value: route.completedTemples,
                label: l10n.tvTemplesVisited,
              ),
              LedgerStat(
                icon: AppIcons.route,
                color: context.palette.accentBlue,
                value: route.remainingTemples,
                label: l10n.tvTemplesRemaining,
              ),
              LedgerStat(
                icon: AppIcons.passport,
                color: context.palette.accentViolet,
                value: route.percent,
                suffix: '%',
                label: l10n.tvPassportProgress,
              ),
            ],
            footer: RouteProgressLine(
              routeName: route.name,
              summary: l10n.tvTemplesOfTotal(route.completedTemples, route.totalTemples),
              percent: route.percent,
            ),
          ).fadeIn(delay: AppDurations.counter),
        ],
      ],
      actions: [AppButton.primary(label: l10n.tvViewFullPassport, icon: AppIcons.passport, onPressed: onViewPassport)],
    );
  }
}

/// A passport page: parchment with the temple skyline sketched in, today's
/// stamp struck on it, and the temple name and date inked below.
class _PassportPage extends StatelessWidget {
  const _PassportPage({required this.templeName});

  final String templeName;

  static const double _height = 220;
  static const double _stamp = 132;
  static const Duration _strike = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    final ink = context.scheme.primary;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(DateTime.now());
    return Container(
      height: _height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppGradients.parchment,
        borderRadius: AppRadius.card,
        border: Border.all(color: context.colors.gold.withValues(alpha: 0.5)),
        boxShadow: AppShadows.sm,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(opacity: 0.18, child: Image.asset(BrandAssets.skylineLineArt, fit: BoxFit.fitWidth)),
          ),
          Positioned(
            top: AppSpacing.lg,
            right: AppSpacing.lg,
            child: StampSlam(
              delay: _strike,
              child: VisitStamp(templeName: templeName, date: date, color: ink, size: _stamp),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            bottom: AppSpacing.lg,
            right: _stamp + AppSpacing.xl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  templeName.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.brandText.titleMedium.copyWith(color: ink),
                ),
                const Gap(AppSpacing.xxs),
                Text(date.toUpperCase(), style: context.overline.copyWith(color: ink, letterSpacing: 1.4)),
              ],
            ).fadeIn(delay: _strike * 2),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Achievement ───────────────────────────

/// The achievement medal popping in over the skyline amid gold dust, its
/// name and points — and any others this visit earned. Opened from the
/// summary.
class AchievementPhase extends StatelessWidget {
  const AchievementPhase({required this.state, required this.onViewAll, super.key});

  final TempleVisitState state;
  final VoidCallback onViewAll;

  static const double _stage = 248;
  static const double _medal = 168;
  static const double _skyline = 96;
  static const double _badge = 36;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final achievements = state.result?.rewards.achievements ?? const <VisitRewardAchievement>[];
    final first = achievements.firstOrNull;
    final gold = context.colors.gold;

    return Stack(
      children: [
        VisitPhaseBody(
          content: [
            SizedBox(
              height: _stage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: _skyline,
                    child: ExcludeSemantics(
                      child: Image.asset(
                        BrandAssets.skylineLineArt,
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                        opacity: const AlwaysStoppedAnimation(0.22),
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  SparkleField(color: gold, count: 24, burst: true),
                  GlowPulse(
                    color: gold,
                    radius: _medal * 0.7,
                    child: AppEntrance(
                      duration: AppDurations.counter,
                      curve: AppCurves.pop,
                      fromScale: 0.3,
                      child: _AchievementBadge(url: first?.badgeImageUrl, size: _medal),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              first?.name ?? l10n.tvAchievementTitle,
              textAlign: TextAlign.center,
              style: context.displayText.headlineMedium.withColor(context.scheme.secondary),
            ).fadeIn(delay: AppDurations.slow),
            const Gap(AppSpacing.xxs),
            Text(
              l10n.tvAchievementTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.primary),
            ).fadeIn(delay: AppDurations.slow + AppDurations.stagger * 2),
            if ((first?.points ?? 0) > 0) ...[
              const Gap(AppSpacing.lg),
              Center(child: _PointsPill(points: first!.points)).scaleIn(delay: AppDurations.counter),
            ],
            if (achievements.length > 1) ...[
              const Gap(AppSpacing.xl),
              GoldRuleHeader(label: l10n.tvAlsoEarned, count: achievements.length - 1),
              const Gap(AppSpacing.sm),
              VisitLedger(
                rows: [
                  for (final a in achievements.skip(1))
                    VisitRewardRow(
                      leading: _AchievementBadge(url: a.badgeImageUrl, size: _badge),
                      title: a.name,
                      detail: a.points > 0 ? l10n.tvPointsEarned(a.points) : null,
                      detailColor: context.palette.accentViolet,
                    ),
                ],
              ).fadeIn(delay: AppDurations.counter + AppDurations.stagger * 2),
            ],
          ],
          actions: [
            AppButton.primary(label: l10n.tvViewAllAchievements, icon: AppIcons.achievement, onPressed: onViewAll),
          ],
        ),
        const Positioned.fill(child: ConfettiOverlay(particleCount: 40)),
      ],
    );
  }
}

/// An achievement's badge art, or MARG's trishul medal when it has none.
class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = IllustratedIcon(
      asset: BrandAssets.illustrationMedal,
      fallbackIcon: AppIcons.achievement,
      color: context.colors.gold,
      size: size,
    );
    final url = this.url;
    if (url == null || url.isEmpty) return fallback;
    return ClipOval(
      child: AppNetworkImage(url: url, width: size, height: size, fallback: fallback),
    );
  }
}

class _PointsPill extends StatelessWidget {
  const _PointsPill({required this.points});

  final int points;

  static const double _coin = 32;

  @override
  Widget build(BuildContext context) {
    final gold = context.colors.gold;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.12),
        borderRadius: AppRadius.pill,
        border: Border.all(color: gold.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IllustratedIcon(
            asset: BrandAssets.illustrationPoints,
            fallbackIcon: AppIcons.points,
            color: gold,
            size: _coin,
          ),
          const Gap.h(AppSpacing.sm),
          Text(
            AppLocalizations.of(context).tvPointsEarned(points),
            style: context.textTheme.titleSmall?.bold.withColor(context.scheme.secondary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Continue Journey ───────────────────────────

/// What's next on the route: the next temple as a photo banner (place and
/// distance from here), then the route's progress and every temple of it on
/// parchment — visited in colour, the rest still locked. Opened from the
/// summary.
class ContinueJourneyPhase extends ConsumerWidget {
  const ContinueJourneyPhase({required this.state, required this.onNavigateNext, required this.onViewRoute, super.key});

  final TempleVisitState state;

  /// The next temple's slug, and its details when the route has them.
  final void Function(String slug, RouteTempleInfo? temple) onNavigateNext;
  final void Function(String? routeSlug) onViewRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final route = state.routeProgress;
    final slug = route?.slug;
    final detail = slug == null ? null : ref.watch(routeDetailProvider(slug)).valueOrNull;
    final nextEntry = detail?.nextEntry;
    final nextSlug = nextEntry?.temple.slug ?? route?.nextTemple?.slug;
    final nextName = nextEntry?.temple.name ?? route?.nextTemple?.name;
    final loc = state.location;
    final away = nextEntry == null || loc == null
        ? null
        : const Distance()(
            LatLng(loc.latitude, loc.longitude),
            LatLng(nextEntry.temple.latitude, nextEntry.temple.longitude),
          );

    return VisitPhaseBody(
      content: [
        Text(l10n.tvJourneyContinuesTitle, style: context.displayText.titleLarge.withColor(context.scheme.secondary)),
        const Gap(AppSpacing.md),
        if (nextSlug != null && nextName != null) ...[
          _NextTempleBanner(
            name: nextName,
            place: nextEntry?.temple.location,
            imageUrl: nextEntry?.temple.imageUrl,
            away: away == null ? null : l10n.tvAway(formatDistance(away)),
            onTap: () => onNavigateNext(nextSlug, nextEntry?.temple),
          ).fadeIn(),
          const Gap(AppSpacing.lg),
        ],
        if (route != null) ...[
          GoldRuleHeader(label: l10n.tvRouteProgress),
          const Gap(AppSpacing.sm),
          ParchmentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RouteProgressLine(
                  routeName: route.name,
                  summary: route.isComplete
                      ? l10n.tvRouteCompleted(route.name)
                      : l10n.tvTemplesOfTotal(route.completedTemples, route.totalTemples),
                  percent: route.percent,
                ),
                if (detail != null && detail.route.temples.isNotEmpty) ...[
                  const Gap(AppSpacing.md),
                  const GoldRule(),
                  const Gap(AppSpacing.md),
                  Text(
                    l10n.tvTemplesCompleted,
                    style: context.textTheme.labelLarge?.semiBold.withColor(context.scheme.secondary),
                  ),
                  const Gap(AppSpacing.sm),
                  _RouteTempleStrip(detail: detail),
                ],
              ],
            ),
          ).fadeIn(delay: AppDurations.stagger * 2),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Text(
              l10n.tvJourneyNoRoute,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.withColor(context.colors.textSecondary),
            ),
          ),
      ],
      actions: [
        if (nextSlug != null) ...[
          AppButton.primary(
            label: l10n.tvNavigateNextTemple,
            icon: AppIcons.navigation,
            onPressed: () => onNavigateNext(nextSlug, nextEntry?.temple),
          ),
          if (route != null) ...[
            const Gap(AppSpacing.sm),
            AppButton.ghost(label: l10n.tvViewFullRoute, icon: AppIcons.route, onPressed: () => onViewRoute(slug)),
          ],
        ] else if (route != null)
          AppButton.primary(label: l10n.tvViewFullRoute, icon: AppIcons.route, onPressed: () => onViewRoute(slug)),
      ],
    );
  }
}

/// The next temple as a full-bleed photo under a dark scrim — "Next Temple"
/// pill, serif name, place and distance — like the Yatra cards.
class _NextTempleBanner extends StatelessWidget {
  const _NextTempleBanner({required this.name, required this.onTap, this.place, this.imageUrl, this.away});

  final String name;
  final String? place;
  final String? imageUrl;
  final String? away;
  final VoidCallback onTap;

  static const double _height = 196;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const white = Colors.white;
    final dim = white.withValues(alpha: 0.8);
    final place = this.place;
    final imageUrl = this.imageUrl;
    final away = this.away;
    return Semantics(
      button: true,
      label: '${l10n.tvNextTemple}, $name',
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: SizedBox(
          height: _height,
          child: Material(
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl == null)
                    const BrandedImageFallback()
                  else
                    AppNetworkImage(url: imageUrl, fit: BoxFit.cover, fallback: const BrandedImageFallback()),
                  const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.photoScrim)),
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    child: PhotoPill(
                      label: l10n.tvNextTemple,
                      icon: AppIcons.temple,
                      color: context.palette.accentSaffron,
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.displayText.titleLarge.copyWith(color: white),
                              ),
                              if (place != null) Text(place, style: context.textTheme.bodySmall?.copyWith(color: dim)),
                              if (away != null) ...[
                                const Gap(AppSpacing.xxs),
                                Row(
                                  children: [
                                    Icon(AppIcons.location, size: 14, color: context.colors.gold),
                                    const Gap.h(AppSpacing.xxs),
                                    Text(away, style: context.caption.copyWith(color: dim)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Gap.h(AppSpacing.sm),
                        const Icon(AppIcons.arrowForward, color: white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Every temple of the route in order — visited ones in colour with a tick,
/// the rest in stone under a lock.
class _RouteTempleStrip extends StatelessWidget {
  const _RouteTempleStrip({required this.detail});

  final RouteDetailBundle detail;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: detail.route.temples.length,
        separatorBuilder: (_, _) => const Gap.h(AppSpacing.sm),
        itemBuilder: (context, i) {
          final entry = detail.route.temples[i];
          final done = detail.isCompleted(entry);
          final url = entry.temple.imageUrl;
          final art = url == null
              ? ColoredBox(color: context.colors.templeSand)
              : AppNetworkImage(
                  url: url,
                  fit: BoxFit.cover,
                  fallback: ColoredBox(color: context.colors.templeSand),
                );
          return Semantics(
            label: entry.temple.name,
            child: ClipRRect(
              borderRadius: AppRadius.thumb,
              child: SizedBox.square(
                dimension: _size,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (done)
                      art
                    else
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                        child: Opacity(opacity: 0.45, child: art),
                      ),
                    if (!done)
                      Center(
                        child: Container(
                          padding: AppSpacing.allXs,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.card.withValues(alpha: 0.9),
                          ),
                          child: Icon(AppIcons.lock, size: 16, color: context.colors.textSecondary),
                        ),
                      ),
                    if (done)
                      Positioned(
                        right: AppSpacing.xxs,
                        bottom: AppSpacing.xxs,
                        child: Icon(AppIcons.success, size: 16, color: context.colors.success, fill: 1),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────── Check-In Failed ───────────────────────────

class FailurePhase extends StatelessWidget {
  const FailurePhase({required this.failure, required this.onRetry, required this.onGoBack, super.key});

  final CheckinFailure failure;
  final VoidCallback onRetry;
  final VoidCallback onGoBack;

  static const double _stage = 180;
  static const double _art = 112;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = context.scheme.error;
    final hints = _hints(l10n);

    return VisitPhaseBody(
      content: [
        SizedBox(
          height: _stage,
          child: Center(
            child: GlowPulse(
              color: error.withValues(alpha: 0.5),
              radius: _art * 0.75,
              child: ShakeIn(
                delay: AppDurations.normal,
                child: IllustratedIcon(
                  asset: BrandAssets.illustrationCheckinFailed,
                  fallbackIcon: AppIcons.error,
                  color: error,
                  size: _art,
                ),
              ),
            ),
          ),
        ),
        Text(l10n.tvFailureTitle, textAlign: TextAlign.center, style: context.displayText.titleLarge.withColor(error)),
        const Gap(AppSpacing.sm),
        // The backend's own message — never hardcoded.
        Text(
          failure.message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.withColor(context.colors.textSecondary),
        ),
        const Gap(AppSpacing.lg),
        AppCard(
          child: Column(
            children: [
              for (final (i, (icon, title, body)) in hints.indexed) ...[
                if (i > 0) const AppDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      VisitIconDisc(icon: icon, color: i == 0 ? error : context.scheme.primary),
                      const Gap.h(AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary),
                            ),
                            Text(body, style: context.caption.copyWith(color: context.colors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).fadeIn(delay: AppDurations.slow + AppDurations.stagger * i),
              ],
            ],
          ),
        ),
      ],
      actions: [
        AppButton.primary(label: l10n.tvTryAgain, icon: AppIcons.refresh, onPressed: onRetry),
        const Gap(AppSpacing.sm),
        AppButton.outlined(label: l10n.tvGoBack, icon: AppIcons.back, onPressed: onGoBack),
      ],
    );
  }

  List<(IconData, String, String)> _hints(AppLocalizations l10n) => switch (failure.kind) {
    CheckinFailureKind.outOfGeofence => [
      (AppIcons.location, l10n.tvHintOutsideTitle, l10n.tvHintOutsideBody),
      (AppIcons.myLocation, l10n.tvHintAccuracyTitle, l10n.tvHintAccuracyBody),
      (AppIcons.cloudOff, l10n.tvHintConnectionTitle, l10n.tvHintConnectionBody),
    ],
    CheckinFailureKind.mockLocation => [(AppIcons.shield, l10n.tvHintMockTitle, l10n.tvHintMockBody)],
    CheckinFailureKind.alreadyCheckedIn => [(AppIcons.info, l10n.tvHintDuplicateTitle, l10n.tvHintDuplicateBody)],
    CheckinFailureKind.rateLimited => [(AppIcons.timer, l10n.tvHintRateTitle, l10n.tvHintRateBody)],
    CheckinFailureKind.offline => [(AppIcons.cloudOff, l10n.tvHintConnectionTitle, l10n.tvHintConnectionBody)],
    CheckinFailureKind.notFound || CheckinFailureKind.unknown => [
      (AppIcons.location, l10n.tvHintOutsideTitle, l10n.tvHintOutsideBody),
      (AppIcons.cloudOff, l10n.tvHintConnectionTitle, l10n.tvHintConnectionBody),
    ],
  };
}
