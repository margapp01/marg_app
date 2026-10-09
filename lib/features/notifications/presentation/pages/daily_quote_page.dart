import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/hub_content.dart';
import '../controllers/notification_controllers.dart';

/// Screen 4 — Daily Quote: today's quote (share-able) + previous quotes.
/// (There is no quote-bookmark endpoint, so no bookmark action is shown.)
class DailyQuotePage extends ConsumerWidget {
  const DailyQuotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final daily = ref.watch(dailyQuoteProvider);
    final previous = ref.watch(previousQuotesProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ntDailyQuote)),
      body: daily.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.ntErrorTitle, message: l10n.ntErrorBody, onRetry: () => ref.invalidate(dailyQuoteProvider)),
        data: (quote) {
          if (quote == null) {
            return EmptyView(art: StateArt.knowledge, icon: AppIcons.article, title: l10n.ntNoQuote, message: l10n.ntNoQuoteBody);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dailyQuoteProvider);
              ref.invalidate(previousQuotesProvider);
            },
            child: ListView(
              padding: AppSpacing.screenAll,
              children: [
                _QuoteHero(quote: quote),
                const Gap(AppSpacing.lg),
                SectionHeader(title: l10n.ntPreviousQuotes),
                const Gap(AppSpacing.sm),
                previous.when(
                  loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.lg), child: Center(child: CircularProgressIndicator(strokeWidth: 2.5))),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (quotes) {
                    final rest = quotes.where((q) => q.id != quote.id).take(12).toList();
                    if (rest.isEmpty) return const SizedBox.shrink();
                    return Column(children: [for (final q in rest) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm), child: _QuoteRow(quote: q))]);
                  },
                ),
                const Gap(AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuoteHero extends StatelessWidget {
  const _QuoteHero({required this.quote});
  final Quote quote;

  Future<void> _share() => SharePlus.instance.share(ShareParams(text: _shareText(quote)));

  static String _shareText(Quote q) {
    final attribution = q.attribution;
    return '"${q.text}"${attribution.isEmpty ? '' : '\n— $attribution'}\n\n— via MARG';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.colors.gold.withValues(alpha: 0.14), context.scheme.primary.withValues(alpha: 0.06)],
        ),
        border: Border.all(color: context.colors.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(AppIcons.aarti, color: context.colors.gold),
          const Gap(AppSpacing.md),
          if (quote.textHi != null)
            Text(quote.textHi!, style: context.brandText.headlineSmall.copyWith(height: 1.6), textAlign: TextAlign.center),
          if (quote.textHi != null) const Gap(AppSpacing.sm),
          Text(quote.text, style: context.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic, height: 1.5), textAlign: TextAlign.center),
          if (quote.attribution.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            Text('— ${quote.attribution}', style: context.textTheme.bodySmall?.semiBold.copyWith(color: context.scheme.primary)),
          ],
          const Gap(AppSpacing.lg),
          AppButton.primary(label: l10n.ntShare, icon: AppIcons.share, expand: false, onPressed: _share),
        ],
      ),
    );
  }
}

class _QuoteRow extends StatelessWidget {
  const _QuoteRow({required this.quote});
  final Quote quote;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(quote.text, style: context.textTheme.bodyMedium?.copyWith(height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
          if (quote.attribution.isNotEmpty) ...[
            const Gap(AppSpacing.xs),
            Text('— ${quote.attribution}', style: context.caption.copyWith(color: context.colors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
