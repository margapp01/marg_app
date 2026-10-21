import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../shared/design_system.dart';
import '../../../../notifications/presentation/controllers/push_messaging.dart';

/// Onboarding's notification ask: why MARG notifies (cards nearby, unlocks,
/// festivals) and one button that raises the system prompt. Shows the result
/// in place — on, or how to turn it on later.
class NotificationPermissionCard extends ConsumerStatefulWidget {
  const NotificationPermissionCard({super.key});

  @override
  ConsumerState<NotificationPermissionCard> createState() => _NotificationPermissionCardState();
}

enum _Phase { unknown, asking, allowed, blocked }

class _NotificationPermissionCardState extends ConsumerState<NotificationPermissionCard> {
  _Phase _phase = _Phase.unknown;

  @override
  void initState() {
    super.initState();
    ref.read(pushMessagingProvider).isAllowed().then((allowed) {
      if (allowed && mounted) setState(() => _phase = _Phase.allowed);
    });
  }

  Future<void> _ask() async {
    setState(() => _phase = _Phase.asking);
    final allowed = await ref.read(pushMessagingProvider).requestPermission();
    if (mounted) setState(() => _phase = allowed ? _Phase.allowed : _Phase.blocked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allowed = _phase == _Phase.allowed;
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        gradient: AppGradients.parchment,
        borderRadius: AppRadius.card,
        border: Border.all(color: context.colors.gold.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.allSm,
                decoration: BoxDecoration(
                  color: (allowed ? context.colors.success : context.scheme.primary).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  allowed ? AppIcons.success : AppIcons.notifications,
                  color: allowed ? context.colors.success : context.scheme.primary,
                ),
              ),
              const Gap.h(AppSpacing.md),
              Expanded(
                child: Text(
                  allowed ? l10n.suNotifOn : l10n.suNotifTitle,
                  style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.secondary),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          Text(
            _phase == _Phase.blocked ? l10n.suNotifBlocked : l10n.suNotifBody,
            style: context.textTheme.bodyMedium?.withColor(context.colors.textSecondary),
          ),
          if (!allowed && _phase != _Phase.blocked) ...[
            const Gap(AppSpacing.md),
            AppButton.secondary(
              label: l10n.suNotifAllow,
              icon: AppIcons.notifications,
              busy: _phase == _Phase.asking,
              onPressed: _ask,
            ),
          ],
        ],
      ),
    ).fadeIn();
  }
}
