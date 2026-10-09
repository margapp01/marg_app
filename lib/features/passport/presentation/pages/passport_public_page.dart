import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../controllers/passport_controllers.dart';
import '../widgets/passport_widgets.dart';

/// Public Passport — a preview of exactly what other pilgrims see when they open
/// the shared public link. Backed by the same `GET /my/passport/share` summary
/// (the public payload); no private stats are exposed here.
class PassportPublicPage extends ConsumerWidget {
  const PassportPublicPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportShareProvider);
    final link = ref.watch(passportShareLinkProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ppPublicPassport)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(title: l10n.ppErrorTitle, message: l10n.ppErrorBody, onRetry: () => ref.invalidate(passportShareProvider)),
        data: (share) => ListView(
          padding: AppSpacing.screenAll,
          children: [
            Container(
              padding: AppSpacing.allMd,
              decoration: BoxDecoration(
                color: context.scheme.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.lgAll,
              ),
              child: Row(
                children: [
                  Icon(AppIcons.info, size: 20, color: context.scheme.primary),
                  const Gap(AppSpacing.sm),
                  Expanded(child: Text(l10n.ppPublicNote, style: context.textTheme.bodySmall)),
                ],
              ),
            ),
            const Gap(AppSpacing.lg),
            PassportShareCard(share: share, qrData: link.valueOrNull),
          ],
        ),
      ),
    );
  }
}
