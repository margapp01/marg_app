import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/achievement_summary.dart';
import '../controllers/achievements_controllers.dart';
import '../widgets/achievement_widgets.dart';

/// Achievement Detail — a night-sky showcase of the medal in a gilt frame
/// (the image that "Share" sends), then unlock facts, progress and reward.
class AchievementDetailPage extends ConsumerStatefulWidget {
  const AchievementDetailPage({required this.achievementId, super.key});

  final String achievementId;

  @override
  ConsumerState<AchievementDetailPage> createState() => _AchievementDetailPageState();
}

class _AchievementDetailPageState extends ConsumerState<AchievementDetailPage> {
  final _shareKey = GlobalKey();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(achievementDetailProvider(widget.achievementId));

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(l10n.acDetailTitle),
        actions: [
          IconButton(icon: const Icon(AppIcons.share), tooltip: l10n.acShare, onPressed: _sharing ? null : _share),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.acErrorTitle,
          message: l10n.acErrorBody,
          onRetry: () => ref.invalidate(achievementDetailProvider(widget.achievementId)),
        ),
        data: (detail) => _content(context, l10n, detail.achievement, detail.reward),
      ),
    );
  }

  Widget _content(BuildContext context, AppLocalizations l10n, Achievement a, AchievementReward? reward) {
    final accent = rarityColor(context, a.rarity);
    return ListView(
      padding: AppSpacing.screenAll,
      children: [
        RepaintBoundary(key: _shareKey, child: _Showcase(achievement: a)),
        const Gap(AppSpacing.lg),
        _Facts(achievement: a),
        const Gap(AppSpacing.lg),
        SectionHeader(title: l10n.acYourProgress),
        const Gap(AppSpacing.sm),
        AppCard(
          child: a.earned
              ? Row(
                  children: [
                    Icon(AppIcons.success, color: context.colors.success, fill: 1),
                    const Gap.h(AppSpacing.sm),
                    Text(l10n.acStatusCompleted, style: context.textTheme.bodyMedium?.semiBold.withColor(context.colors.success)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.threshold != null ? '${a.currentCount} / ${a.threshold}' : l10n.acInProgress,
                            style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary),
                          ),
                        ),
                        Text('${a.percent}%', style: context.textTheme.bodyMedium?.bold.withColor(accent)),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    AppLinearProgress(value: (a.percent / 100).clamp(0, 1), color: accent),
                  ],
                ),
        ),
        if (reward != null) ...[
          const Gap(AppSpacing.lg),
          SectionHeader(title: l10n.acReward),
          const Gap(AppSpacing.sm),
          _RewardRow(reward: reward),
        ],
        const Gap(AppSpacing.xl),
        AppButton.primary(label: l10n.acShareAchievement, icon: AppIcons.share, busy: _sharing, onPressed: _share),
      ],
    );
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _sharing = true);
    try {
      await shareBoundaryImage(_shareKey, text: l10n.acShareBody, fileName: 'marg-achievement.png');
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.acErrorBody);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}

/// The medal on a night sky inside the gilt frame: name in the brand face,
/// rarity ribbon, description and the MARG line.
class _Showcase extends StatelessWidget {
  const _Showcase({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final light = context.colors.card;
    final locked = achievement.locked;
    return GiltFrame(
      accent: rarityColor(context, achievement.rarity),
      locked: locked,
      large: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xl),
          child: Column(
            children: [
              ScaleIn(child: AchievementMedal(achievement: achievement, size: 136, hero: true)),
              const Gap(AppSpacing.lg),
              Text(
                achievement.name,
                textAlign: TextAlign.center,
                style: context.brandText.headlineSmall.copyWith(
                  color: locked ? light.withValues(alpha: 0.7) : Color.lerp(context.colors.gold, light, 0.3),
                ),
              ),
              const Gap(AppSpacing.md),
              RarityRibbon(rarity: achievement.rarity),
              if (achievement.description != null && achievement.description!.isNotEmpty) ...[
                const Gap(AppSpacing.md),
                Text(
                  achievement.description!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(color: light.withValues(alpha: 0.82), height: 1.5),
                ),
              ],
              const Gap(AppSpacing.lg),
              Text(l10n.acBrandTagline, style: context.caption.copyWith(color: context.colors.gold.withValues(alpha: 0.8))),
            ],
          ),
        ),
      ),
    );
  }
}

/// Unlock date and points, side by side.
class _Facts extends StatelessWidget {
  const _Facts({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final at = achievement.earnedAt;
    return AppCard(
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (at != null) ...[
              _fact(context, AppIcons.calendar, p.accentSaffron, DateFormat('d MMM yyyy').format(at.toLocal()), l10n.acUnlockedOn),
              VerticalDivider(width: AppSpacing.lg, color: context.colors.divider),
            ],
            _fact(context, AppIcons.points, context.colors.gold, '${achievement.points}', l10n.acPointsEarned),
          ],
        ),
      ),
    );
  }

  Widget _fact(BuildContext context, IconData icon, Color color, String value, String label) => Expanded(
        child: Row(
          children: [
            IllustratedIcon(fallbackIcon: icon, color: color, size: 40),
            const Gap.h(AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: context.textTheme.titleSmall?.bold.withColor(context.scheme.secondary)),
                  Text(label, style: context.caption.copyWith(color: context.colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      );
}

/// The Sacred Card this achievement awards, as a miniature gilt card.
class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.reward});

  final AchievementReward reward;

  static const double _thumbWidth = 48;

  @override
  Widget build(BuildContext context) {
    final accent = rarityColor(context, reward.rarity);
    return AppCard(
      child: Row(
        children: [
          SizedBox(
            width: _thumbWidth,
            child: GiltFrame(
              accent: accent,
              aspectRatio: 3 / 4,
              child: reward.imageUrl.isEmpty
                  ? ColoredBox(color: accent.withValues(alpha: 0.15))
                  : AppNetworkImage(url: reward.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(AppSpacing.xxs),
                RarityChip(rarity: reward.rarity, compact: true),
              ],
            ),
          ),
          Icon(AppIcons.card, color: accent),
        ],
      ),
    );
  }
}
