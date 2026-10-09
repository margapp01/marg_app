import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../components/app_card.dart';
import '../images/app_avatar.dart';

/// A user summary card: avatar, name, subtitle (e.g. rank / handle), an
/// optional trailing widget (badge, chevron), and an optional row of stats
/// below. Content-only — pass data in, no API calls.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.trailing,
    this.stats = const [],
    this.onTap,
    super.key,
  });

  final String name;
  final String? subtitle;
  final String? imageUrl;
  final Widget? trailing;

  /// Optional metric chips shown under the header (label + value pairs).
  final List<ProfileStat> stats;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(imageUrl: imageUrl, name: name, radius: 28),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: context.textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle!,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(color: context.colors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                for (final stat in stats)
                  Expanded(
                    child: Column(
                      children: [
                        Text(stat.value, style: context.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          stat.label,
                          style: context.textTheme.labelSmall
                              ?.copyWith(color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A single label/value pair shown in a [ProfileCard]'s stats row.
class ProfileStat {
  const ProfileStat({required this.label, required this.value});

  final String label;
  final String value;
}
