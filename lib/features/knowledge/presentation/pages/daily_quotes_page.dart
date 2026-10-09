import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/knowledge_models.dart';
import '../controllers/knowledge_controllers.dart';
import '../widgets/knowledge_share.dart';
import '../widgets/knowledge_widgets.dart';

/// Screen 4 — Daily Quotes. Shows the deterministic verse of the day (Hindi +
/// English + scripture reference) with copy + a branded share card. There is no
/// public quote archive endpoint, so a "Previous Quotes" list is not shown.
class DailyQuotesPage extends ConsumerWidget {
  const DailyQuotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(dailyQuoteProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.kbDailyQuotes)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(dailyQuoteProvider)),
        data: (quote) {
          if (quote == null) {
            return EmptyView(art: StateArt.knowledge, icon: AppIcons.quote, title: l10n.kbNoQuote, message: l10n.kbNoQuoteBody);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dailyQuoteProvider),
            child: ListView(
              padding: AppSpacing.screenAll,
              children: [
                Text(l10n.kbTodaysQuote, style: context.overline.copyWith(color: context.colors.textSecondary)),
                const Gap(AppSpacing.sm),
                AppCard(
                  padding: AppSpacing.allLg,
                  child: QuoteView(quote: quote),
                ),
                const Gap(AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppButton.outlined(
                        label: l10n.kbCopy,
                        icon: AppIcons.copy,
                        onPressed: () => _copy(context, quote, l10n),
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    Expanded(
                      child: AppButton.primary(
                        label: l10n.kbShare,
                        icon: AppIcons.share,
                        onPressed: () => showKnowledgeShare(context, _share(quote)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _copy(BuildContext context, Quote quote, AppLocalizations l10n) {
    final text = [if (quote.textHi != null) quote.textHi, quote.text, if (quote.attribution.isNotEmpty) '— ${quote.attribution}']
        .whereType<String>()
        .join('\n');
    Clipboard.setData(ClipboardData(text: text));
    AppSnackbar.success(context, l10n.kbCopied);
  }

  ShareContent _share(Quote quote) => ShareContent(
        title: quote.text,
        verse: quote.textHi ?? quote.text,
        attribution: quote.attribution.isEmpty ? null : quote.attribution,
        shareText: [if (quote.textHi != null) quote.textHi, quote.text, if (quote.attribution.isNotEmpty) '— ${quote.attribution}']
            .whereType<String>()
            .join('\n'),
      );
}
