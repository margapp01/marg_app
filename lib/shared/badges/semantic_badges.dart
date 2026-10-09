import 'package:flutter/widgets.dart';

import '../../app/theme/app_icons.dart';
import '../animations/app_entrance.dart';
import 'app_badge.dart';

/// Generic status pill (Active / Pending / Draft …). Map a backend status to a
/// [tone] at the call site — this widget stays domain-agnostic.
class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, this.tone = AppBadgeTone.neutral, this.icon, super.key});

  final String label;
  final AppBadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => AppBadge(label: label, tone: tone, icon: icon);
}

/// Verified / unverified indicator (temples, users).
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({this.verified = true, this.label, super.key});

  final bool verified;
  final String? label;

  @override
  Widget build(BuildContext context) => AppBadge(
        label: label ?? (verified ? 'Verified' : 'Unverified'),
        tone: verified ? AppBadgeTone.success : AppBadgeTone.neutral,
        icon: verified ? AppIcons.verified : null,
      );
}

/// Trust-score chip. Tone steps by score band (low → high).
class TrustBadge extends StatelessWidget {
  const TrustBadge({required this.score, super.key});

  final int score;

  AppBadgeTone get _tone {
    if (score >= 75) return AppBadgeTone.success;
    if (score >= 40) return AppBadgeTone.warning;
    return AppBadgeTone.error;
  }

  @override
  Widget build(BuildContext context) =>
      AppBadge(label: 'Trust $score', tone: _tone, icon: AppIcons.shield);
}

/// Points / reward chip.
class PointsBadge extends StatelessWidget {
  const PointsBadge({required this.points, this.solid = false, super.key});

  final int points;
  final bool solid;

  @override
  Widget build(BuildContext context) =>
      AppBadge(label: '$points', tone: AppBadgeTone.gold, icon: AppIcons.points, solid: solid);
}

/// Medal tier for achievements / leaderboards.
enum AchievementTier { gold, silver, bronze }

/// Achievement / rank tier badge (gold, silver, bronze medal).
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({required this.tier, this.label, super.key});

  final AchievementTier tier;
  final String? label;

  AppBadgeTone get _tone => switch (tier) {
        AchievementTier.gold => AppBadgeTone.gold,
        AchievementTier.silver => AppBadgeTone.silver,
        AchievementTier.bronze => AppBadgeTone.bronze,
      };

  @override
  Widget build(BuildContext context) => AppBadge(
        label: label ?? tier.name[0].toUpperCase() + tier.name.substring(1),
        tone: _tone,
        icon: AppIcons.achievement,
        solid: true,
      );
}

/// Wraps any badge so it pops in when it first appears (e.g. a newly earned
/// achievement). Purposeful emphasis, used sparingly.
class AnimatedBadge extends StatelessWidget {
  const AnimatedBadge({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => ScaleIn(from: 0.6, child: child);
}
