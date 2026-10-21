import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/storage/shared_prefs_store.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../features/profile/presentation/controllers/profile_controllers.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/yatra_route.dart';

/// The completion medal — the shared [GoldSeal] at showcase size.
class CompletionMedal extends StatelessWidget {
  const CompletionMedal({this.size = 128, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => GoldSeal(icon: AppIcons.route, size: size, glow: true);
}

/// A premium, printable-style completion certificate rendered from real data:
/// parchment in the collectibles' gilt frame. The PDF comes from the backend.
class CertificateCard extends StatelessWidget {
  const CertificateCard({
    required this.routeName,
    required this.userName,
    this.completedOn,
    super.key,
  });

  final String routeName;
  final String userName;
  final DateTime? completedOn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary);
    final date = completedOn;
    return GiltFrame(
      accent: context.colors.gold,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.parchment),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
          child: Column(
            children: [
              Text(
                l10n.ryCertificateTitle.toUpperCase(),
                textAlign: TextAlign.center,
                style: context.overline.copyWith(color: context.colors.gold, letterSpacing: 1.6),
              ),
              const Gap(AppSpacing.md),
              Text(l10n.ryCertifyThat, style: muted, textAlign: TextAlign.center),
              const Gap(AppSpacing.xs),
              Text(userName, style: context.brandText.headlineSmall, textAlign: TextAlign.center),
              const Gap(AppSpacing.xs),
              Text(l10n.ryHasCompleted, style: muted, textAlign: TextAlign.center),
              const Gap(AppSpacing.xs),
              Text(
                routeName,
                style: context.displayText.titleLarge.withColor(context.scheme.primary),
                textAlign: TextAlign.center,
              ),
              const Gap(AppSpacing.md),
              Text(l10n.ryBlessings, style: muted?.copyWith(fontStyle: FontStyle.italic), textAlign: TextAlign.center),
              const Gap(AppSpacing.lg),
              const GoldSeal(),
              const Gap(AppSpacing.lg),
              const GoldRule(),
              const Gap(AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (date != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(date),
                          style: context.textTheme.bodySmall?.semiBold,
                        ),
                        Text(l10n.ryCertDate, style: context.caption.copyWith(color: context.colors.textSecondary)),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const BrandLogo(size: 18),
                      Text(l10n.ryCertIssuer, style: context.caption.copyWith(color: context.colors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The route's reward card in the gilt frame, glowing in its rarity colour.
class RewardCardArt extends StatelessWidget {
  const RewardCardArt({required this.card, super.key});

  final RouteRewardCard card;

  static const double _maxWidth = 200;

  @override
  Widget build(BuildContext context) {
    final accent = rarityColor(context, card.rarity);
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: GiltFrame(
            accent: accent,
            large: true,
            aspectRatio: 3 / 4,
            child: card.imageUrl.isEmpty
                ? ColoredBox(color: accent.withValues(alpha: 0.15))
                : AppNetworkImage(url: card.imageUrl, fit: BoxFit.cover),
          ),
        ),
        const Gap(AppSpacing.md),
        Text(card.title, style: context.textTheme.titleSmall?.semiBold, textAlign: TextAlign.center),
        Text(rarityLabel(AppLocalizations.of(context), card.rarity), style: context.caption.copyWith(color: accent)),
      ],
    );
  }
}

/// The Yatra completion prize as a scratch card — whichever [prizes] the route
/// offers (admin-set: a MARG T-shirt and/or a mobile recharge on the
/// registered mobile). Before completion the card shows the prize artwork,
/// locked, with what's left to do below; once complete it turns to gold foil
/// to scratch; scratched, it shows the won artwork and the prizes in detail
/// (remembered on this device for this account). The terms sit beneath.
/// Callers skip it when [RoutePrizes.isEmpty].
class YatraScratchReward extends ConsumerStatefulWidget {
  const YatraScratchReward({
    required this.routeId,
    required this.prizes,
    required this.complete,
    required this.templesLeft,
    super.key,
  });

  final String routeId;
  final RoutePrizes prizes;
  final bool complete;
  final int templesLeft;

  @override
  ConsumerState<YatraScratchReward> createState() => _YatraScratchRewardState();
}

class _YatraScratchRewardState extends ConsumerState<YatraScratchReward> {
  /// Every face of the card shares the artwork's 16:10 shape.
  static const double _ratio = 16 / 10;

  bool? _scratched;

  String get _key => 'rewards.yatraScratch.${ref.read(authControllerProvider).user?.id ?? ''}.${widget.routeId}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    bool seen;
    try {
      seen = await ref.read(keyValueStoreProvider).getBool(_key) ?? false;
    } catch (_) {
      seen = false; // unreadable storage: offer the scratch again
    }
    if (mounted) setState(() => _scratched = seen);
  }

  Future<void> _onRevealed() async {
    setState(() => _scratched = true);
    try {
      await ref.read(keyValueStoreProvider).setBool(_key, value: true);
    } catch (_) {/* stays revealed for this visit */}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scratched = _scratched;
    final revealed = widget.complete && (scratched ?? false);
    final art = _RewardArt.of(widget.prizes);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GiltFrame(
          accent: context.colors.gold,
          child: AspectRatio(
            aspectRatio: _ratio,
            child: scratched == null
                ? const SkeletonBox(height: double.infinity, radius: BorderRadius.zero)
                : ScratchCard(
                    key: ValueKey(widget.complete),
                    revealed: revealed,
                    enabled: widget.complete,
                    semanticLabel: widget.complete ? l10n.ryScratchSemantics : l10n.ryScratchLocked,
                    onRevealed: _onRevealed,
                    cover: widget.complete ? const _GoldFoil() : _LockedArt(image: art.teaser),
                    child: _WonFace(image: art.won),
                  ),
          ),
        ),
        const Gap(AppSpacing.md),
        if (!widget.complete)
          _LockedDetails(prizes: widget.prizes, templesLeft: widget.templesLeft)
        else if (revealed) ...[
          _PrizeList(prizes: widget.prizes),
          const Gap(AppSpacing.md),
          const _RechargeNumber(),
        ],
        const Gap(AppSpacing.sm),
        Text(_terms(l10n, widget.prizes), style: context.caption.copyWith(color: context.colors.textSecondary)),
      ],
    );
  }
}

/// The artwork for a route's prizes: the locked teaser and the won face.
/// Recharge-only routes have no artwork yet and fall back to the gold design.
class _RewardArt {
  const _RewardArt(this.teaser, this.won);

  final String? teaser;
  final String? won;

  static _RewardArt of(RoutePrizes prizes) {
    if (prizes.tshirt && prizes.recharge) return const _RewardArt(BrandAssets.rewardBoth, BrandAssets.rewardWon);
    if (prizes.tshirt) return const _RewardArt(BrandAssets.rewardTshirt, BrandAssets.rewardTshirt);
    return const _RewardArt(null, null);
  }
}

String _inr(int amount) => NumberFormat.decimalPattern('en_IN').format(amount);

String _terms(AppLocalizations l10n, RoutePrizes prizes) {
  final months = prizes.rechargeMonths;
  final amount = _inr(prizes.rechargeMaxInr);
  if (prizes.tshirt && prizes.recharge) return l10n.ryScratchTermsBoth(months, amount);
  if (prizes.recharge) return l10n.ryScratchTermsRecharge(months, amount);
  return l10n.ryScratchTermsTshirt;
}

Widget _art(String asset) => Image.asset(
      asset,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.gilt)),
    );

/// Before completion: the prizes to win, with a "Locked" tag and — in the
/// artwork's calm left side — a "Scratch & Win" headline.
class _LockedArt extends StatelessWidget {
  const _LockedArt({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ink = context.scheme.secondary;
    final art = image;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (art != null) ...[
          _art(art),
          const _ScratchHeadline(),
        ] else
          DecoratedBox(
            decoration: const BoxDecoration(gradient: AppGradients.gilt),
            child: Center(child: Icon(AppIcons.referral, size: 56, color: ink)),
          ),
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(color: ink.withValues(alpha: 0.85), borderRadius: AppRadius.fullAll),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.lock, size: 14, color: context.colors.gold),
                const Gap.h(AppSpacing.xxs),
                Text(l10n.ryScratchLockedBadge, style: context.textTheme.labelSmall?.bold.withColor(context.colors.card)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// "Scratch & Win" over the left of the locked artwork (kept clear of the
/// prizes on the right; scales down on narrow cards).
class _ScratchHeadline extends StatelessWidget {
  const _ScratchHeadline();

  /// The artwork keeps its left ~45% calm for this.
  static const double _widthFactor = 0.44;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final navy = context.scheme.secondary;
    final style = context.brandText.headlineMedium;
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: _widthFactor,
        heightFactor: 0.62,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.ryScratchHeadlineTop, style: style.copyWith(color: navy, height: 1)),
                Text(l10n.ryScratchHeadlineBottom, style: style.copyWith(color: context.scheme.primary, height: 1.1)),
                const Gap(AppSpacing.xs),
                Container(width: 36, height: 3, decoration: BoxDecoration(color: context.colors.gold, borderRadius: AppRadius.fullAll)),
                const Gap(AppSpacing.xs),
                Text(l10n.ryScratchWinLabel, style: context.textTheme.labelMedium?.semiBold.withColor(navy)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Once complete: gold foil to scratch away.
class _GoldFoil extends StatelessWidget {
  const _GoldFoil();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ink = context.scheme.secondary;
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.gilt),
      child: Padding(
        padding: AppSpacing.allLg,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.referral, size: 44, color: ink),
              const Gap(AppSpacing.sm),
              Text(l10n.ryScratchCover, textAlign: TextAlign.center, style: context.textTheme.titleMedium?.bold.withColor(ink)),
              const Gap(AppSpacing.xxs),
              Text(
                l10n.ryScratchCoverHint,
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.withColor(ink.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Under the foil: the won artwork with a "You've won!" ribbon.
class _WonFace extends StatelessWidget {
  const _WonFace({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final art = image;
    final ribbon = Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.scheme.secondary.withValues(alpha: 0.9),
        borderRadius: AppRadius.fullAll,
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.referral, size: 18, color: context.colors.gold),
          const Gap.h(AppSpacing.xs),
          Text(l10n.ryScratchWon, style: context.textTheme.titleSmall?.bold.withColor(context.colors.card)),
        ],
      ),
    );
    if (art == null) {
      return DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.parchment),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [const GoldSeal(icon: AppIcons.referral, size: 56), const Gap(AppSpacing.md), ribbon],
          ),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        _art(art),
        Positioned(left: 0, right: 0, bottom: AppSpacing.sm, child: Center(child: ribbon)),
      ],
    );
  }
}

/// Below the locked card: what's left to do and what it wins.
class _LockedDetails extends StatelessWidget {
  const _LockedDetails({required this.prizes, required this.templesLeft});

  final RoutePrizes prizes;
  final int templesLeft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ink = context.scheme.secondary;
    return Column(
      children: [
        Text(l10n.ryScratchLocked, textAlign: TextAlign.center, style: context.textTheme.titleMedium?.bold.withColor(ink)),
        const Gap(AppSpacing.xxs),
        Text(
          l10n.ryScratchTemplesLeft(templesLeft),
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
        ),
        const Gap(AppSpacing.md),
        Text(l10n.ryScratchWinLabel.toUpperCase(), style: context.overline.copyWith(color: context.scheme.primary, letterSpacing: 1.2)),
        const Gap(AppSpacing.xs),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            if (prizes.tshirt) _PrizeChip(icon: AppIcons.checkroom, label: l10n.ryScratchTshirt),
            if (prizes.recharge)
              _PrizeChip(
                icon: AppIcons.smartphone,
                label: '${l10n.ryScratchRecharge(prizes.rechargeMonths)} · ${l10n.ryScratchRechargeHint(_inr(prizes.rechargeMaxInr))}',
              ),
          ],
        ),
      ],
    );
  }
}

/// A prize named under the locked card.
class _PrizeChip extends StatelessWidget {
  const _PrizeChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final saffron = context.scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: saffron.withValues(alpha: 0.08),
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: saffron.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: saffron),
          const Gap.h(AppSpacing.xxs),
          Flexible(child: Text(label, style: context.textTheme.labelMedium?.semiBold.withColor(context.scheme.secondary))),
        ],
      ),
    );
  }
}

/// After scratching: each prize in detail.
class _PrizeList extends StatelessWidget {
  const _PrizeList({required this.prizes});

  final RoutePrizes prizes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return AppCard(
      padding: AppSpacing.allMd,
      child: Column(
        children: [
          if (prizes.tshirt)
            _PrizeRow(icon: AppIcons.checkroom, color: p.accentSaffron, title: l10n.ryScratchTshirt, subtitle: l10n.ryScratchTshirtHint),
          if (prizes.tshirt && prizes.recharge) const Gap(AppSpacing.md),
          if (prizes.recharge)
            _PrizeRow(
              icon: AppIcons.smartphone,
              color: p.accentBlue,
              title: l10n.ryScratchRecharge(prizes.rechargeMonths),
              subtitle: l10n.ryScratchRechargeHint(_inr(prizes.rechargeMaxInr)),
            ),
        ],
      ),
    );
  }
}

class _PrizeRow extends StatelessWidget {
  const _PrizeRow({required this.icon, required this.color, required this.title, required this.subtitle});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: AppRadius.mdAll),
          child: Icon(icon, color: color, size: 22),
        ),
        const Gap.h(AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.textTheme.titleSmall?.semiBold),
              Text(subtitle, style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Where the recharge goes — the registered mobile — or a prompt to add one.
class _RechargeNumber extends ConsumerWidget {
  const _RechargeNumber();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final phone = ref.watch(profileProvider.select((a) => a.valueOrNull?.phone))?.trim();
    if (phone != null && phone.isNotEmpty) {
      return AppCard(
        padding: EdgeInsets.zero,
        child: InfoTile(icon: AppIcons.smartphone, label: l10n.ryScratchMobileLabel, value: phone),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.ryScratchAddMobile,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
        ),
        const Gap(AppSpacing.sm),
        AppButton.outlined(
          label: l10n.ryScratchAddMobileCta,
          icon: AppIcons.phone,
          onPressed: () => context.pushNamed(RouteNames.profileEdit),
        ),
      ],
    );
  }
}
