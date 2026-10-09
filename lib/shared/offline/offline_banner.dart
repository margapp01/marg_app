import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../core/services/connectivity_service.dart';
import '../design_system.dart';

/// A slim, animated banner that appears while the device is offline. Watches
/// [connectivityStatusProvider] so any screen can host it with one line. Reused
/// across offline-aware surfaces (Home, Temple Detail, …).
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Treat "unknown" (loading/error) as online — never flash a false banner.
    final online = ref.watch(connectivityStatusProvider).maybeWhen(data: (v) => v, orElse: () => true);

    return AnimatedSize(
      duration: AppDurations.normal,
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: online
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              child: Container(
                width: double.infinity,
                color: context.colors.warning.withValues(alpha: 0.14),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.offline, size: 16, color: context.colors.warning),
                    const Gap(AppSpacing.sm),
                    Flexible(
                      child: Text(
                        l10n.offlineBannerMessage,
                        style: context.caption.copyWith(color: context.colors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
