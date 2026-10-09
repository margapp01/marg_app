import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/search_models.dart';
import 'search_visuals.dart';

/// One search result row. Uniform, premium list style (thumbnail → title +
/// subtitle → chevron). (Rating/crowd/distance aren't in the `/search`
/// contract, so they're intentionally not shown here.)
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    required this.hit,
    required this.onTap,
    super.key,
  });

  final SearchHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = searchTypeColor(context, hit.type);
    final subtitle = searchSubtitle(AppLocalizations.of(context), hit);
    return Semantics(
      button: true,
      label: hit.title,
      child: AppCard(
        variant: AppCardVariant.outlined,
        padding: AppSpacing.allMd,
        onTap: onTap,
        child: Row(
          children: [
            _Thumb(hit: hit, accent: accent),
            const Gap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall?.semiBold,
                  ),
                  if (subtitle != null) ...[
                    const Gap(AppSpacing.xxs),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const Gap.h(AppSpacing.sm),
            Icon(AppIcons.chevronRight, color: context.colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.hit, required this.accent});

  final SearchHit hit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    if (hit.imageUrl != null) {
      return AppNetworkImage(
        url: hit.imageUrl!,
        width: size,
        height: size,
        borderRadius: AppRadius.mdAll,
        placeholderIcon: searchTypeIcon(hit.type),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: AppRadius.mdAll,
      ),
      child: Icon(searchTypeIcon(hit.type), color: accent),
    );
  }
}
