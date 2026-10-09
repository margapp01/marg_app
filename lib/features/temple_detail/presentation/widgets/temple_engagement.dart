import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../data/datasource/temple_detail_remote_datasource.dart';
import '../../domain/entities/temple_detail.dart';
import '../controllers/temple_detail_controller.dart';

/// "Plan Your Visit" — the admin-authored visitor guidance. Each row expands
/// to its full text; rows without data are omitted.
class VisitorInfoSection extends StatelessWidget {
  const VisitorInfoSection({required this.info, super.key});

  final VisitorInfo info;

  String? _photography(AppLocalizations l10n) => switch (info.photographyPolicy) {
        'ALLOWED' => l10n.tdPhotoAllowed,
        'RESTRICTED' => l10n.tdPhotoRestricted,
        'NOT_ALLOWED' => l10n.tdPhotoNotAllowed,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    if (info.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final rows = <(IconData, Color, String, String)>[
      if (info.howToReach != null) (AppIcons.directions, p.accentSaffron, l10n.tdHowToReach, info.howToReach!),
      if (info.parkingInfo != null) (AppIcons.parking, p.accentGreen, l10n.tdParking, info.parkingInfo!),
      if (info.dressCode != null) (AppIcons.checkroom, p.accentViolet, l10n.tdDressCode, info.dressCode!),
      if (_photography(l10n) != null) (AppIcons.camera, p.accentBlue, l10n.tdPhotography, _photography(l10n)!),
      if (info.prasadInfo != null) (AppIcons.restaurant, p.accentAmber, l10n.tdPrasad, info.prasadInfo!),
      if (info.accommodationInfo != null) (AppIcons.hotel, p.accentTeal, l10n.tdStay, info.accommodationInfo!),
      if (info.visitorRules != null) (AppIcons.rule, p.accentRose, l10n.tdRules, info.visitorRules!),
      if (info.bestSeason != null) (AppIcons.season, p.accentSaffron, l10n.tdBestSeason, info.bestSeason!),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.tdPlanVisit),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const AppDivider(),
                _VisitorRow(icon: rows[i].$1, color: rows[i].$2, title: rows[i].$3, body: rows[i].$4),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _VisitorRow extends StatefulWidget {
  const _VisitorRow({required this.icon, required this.color, required this.title, required this.body});

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  State<_VisitorRow> createState() => _VisitorRowState();
}

class _VisitorRowState extends State<_VisitorRow> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _open = !_open),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IllustratedIcon(fallbackIcon: widget.icon, color: widget.color, size: 36),
            const Gap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: context.textTheme.labelLarge?.semiBold),
                  const Gap(AppSpacing.xxs),
                  AnimatedSize(
                    duration: AppDurations.normal,
                    curve: AppCurves.standard,
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.body,
                      maxLines: _open ? null : 2,
                      overflow: _open ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: _open ? 0.25 : 0,
              duration: AppDurations.fast,
              child: Icon(AppIcons.chevronRight, color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reviews & Ratings — average, star distribution, recent reviews and the
/// write/edit entry point.
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    required this.summary,
    required this.reviews,
    required this.myReview,
    required this.canReview,
    required this.onWrite,
    super.key,
  });

  final ReviewSummary summary;
  final List<TempleReview> reviews;
  final TempleReview? myReview;

  /// Reviews are open only after a verified visit (enforced by the backend).
  final bool canReview;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasReviews = summary.count > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.tdReviews),
        AppCard(
          child: Column(
            children: [
              if (hasReviews)
                Row(
                  children: [
                    Column(
                      children: [
                        Text(summary.average.toStringAsFixed(1), style: context.displayText.displaySmall),
                        StarRating(
                          value: summary.average,
                          semanticsLabel: l10n.tdStarsLabel(summary.average.toStringAsFixed(1)),
                        ),
                        const Gap(AppSpacing.xxs),
                        Text(
                          l10n.tdReviewCount(summary.count),
                          style: context.caption.copyWith(color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                    const Gap.h(AppSpacing.xl),
                    Expanded(
                      child: Column(
                        children: [
                          for (var s = 5; s >= 1; s--) _DistributionBar(stars: s, share: summary.share(s)),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Text(
                  l10n.tdNoReviews,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
                ),
              const Gap(AppSpacing.lg),
              if (canReview)
                AppButton.outlined(
                  label: myReview == null ? l10n.tdWriteReview : l10n.tdEditReview,
                  icon: AppIcons.edit,
                  size: AppButtonSize.small,
                  onPressed: onWrite,
                )
              else
                Row(
                  children: [
                    Icon(AppIcons.visit, size: 20, color: context.scheme.primary),
                    const Gap.h(AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.tdReviewVisitRequired,
                        style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (reviews.isNotEmpty) ...[
          const Gap(AppSpacing.md),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const Gap.h(AppSpacing.md),
              itemBuilder: (_, i) => _ReviewCard(review: reviews[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _DistributionBar extends StatelessWidget {
  const _DistributionBar({required this.stars, required this.share});

  final int stars;
  final double share;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          SizedBox(width: AppSpacing.md, child: Text('$stars', style: context.caption)),
          Icon(AppIcons.star, size: 12, color: context.palette.accentAmber, fill: 1),
          const Gap.h(AppSpacing.sm),
          Expanded(
            child: AppLinearProgress(
              value: share,
              height: 6,
              color: context.palette.accentSaffron,
              backgroundColor: context.colors.divider,
            ),
          ),
          const Gap.h(AppSpacing.sm),
          SizedBox(
            width: AppSpacing.xxxl,
            child: Text(
              '${(share * 100).round()}%',
              textAlign: TextAlign.right,
              style: context.caption.copyWith(color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final TempleReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = review.authorName ?? l10n.homeDevotee;
    final when = review.createdAt;
    return SizedBox(
      width: 250,
      child: AppCard(
        variant: AppCardVariant.outlined,
        padding: AppSpacing.allMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(imageUrl: review.authorPhoto, name: name, radius: 16),
                const Gap.h(AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.labelLarge?.semiBold),
                      if (when != null)
                        Text(DateFormat('d MMM yyyy').format(when.toLocal()), style: context.caption.copyWith(color: context.colors.textSecondary)),
                    ],
                  ),
                ),
                if (review.verifiedVisitor)
                  Tooltip(
                    message: l10n.tdVerifiedVisitor,
                    child: Icon(AppIcons.verified, size: 18, color: context.palette.accentGreen, fill: 1),
                  ),
              ],
            ),
            const Gap(AppSpacing.sm),
            StarRating(value: review.rating.toDouble(), size: 14, semanticsLabel: l10n.tdStarsLabel(review.rating)),
            const Gap(AppSpacing.xs),
            Expanded(
              child: Text(
                review.comment,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Write / edit the devotee's review in a bottom sheet; reloads the temple on
/// success so the summary and list reflect it.
Future<void> showReviewSheet(BuildContext context, {required TempleDetail temple, TempleReview? existing}) {
  return AppSheets.show<void>(
    context,
    padded: false,
    builder: (_) => _ReviewSheet(temple: temple, existing: existing),
  );
}

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({required this.temple, required this.existing});

  final TempleDetail temple;
  final TempleReview? existing;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  late int _rating = widget.existing?.rating ?? 0;
  late final _comment = TextEditingController(text: widget.existing?.comment ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(templeDetailRemoteDataSourceProvider).saveReview(
            widget.temple.id,
            rating: _rating,
            comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
          );
      if (!mounted) return;
      ref.invalidate(templeDetailControllerProvider(widget.temple.slug));
      Navigator.of(context).pop();
      AppSnackbar.success(context, l10n.tdReviewSaved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnackbar.error(context, l10n.tdReviewFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSheetLayout(
      title: widget.existing == null ? l10n.tdWriteReview : l10n.tdEditReview,
      subtitle: widget.temple.name,
      actions: [
        AppButton.primary(
          label: l10n.tdSubmitReview,
          busy: _busy,
          onPressed: _rating == 0 ? null : _submit,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetSection(
            label: l10n.tdYourRating,
            child: Center(
              child: StarRating(value: _rating.toDouble(), size: 36, onChanged: (v) => setState(() => _rating = v)),
            ),
          ),
          MultilineField(controller: _comment, hint: l10n.tdReviewHint, maxLength: 1000),
        ],
      ),
    );
  }
}

/// The hero's heart: saves / unsaves the temple optimistically.
class SaveTempleButton extends ConsumerStatefulWidget {
  const SaveTempleButton({required this.templeId, required this.initiallySaved, super.key});

  final String templeId;
  final bool initiallySaved;

  @override
  ConsumerState<SaveTempleButton> createState() => _SaveTempleButtonState();
}

class _SaveTempleButtonState extends ConsumerState<SaveTempleButton> {
  late bool _saved = widget.initiallySaved;

  Future<void> _toggle() async {
    final l10n = AppLocalizations.of(context);
    final next = !_saved;
    setState(() => _saved = next);
    try {
      final api = ref.read(templeDetailRemoteDataSourceProvider);
      await (next ? api.saveTemple(widget.templeId) : api.unsaveTemple(widget.templeId));
      if (mounted) AppSnackbar.info(context, next ? l10n.tdSavedToast : l10n.savedRemoved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saved = !next);
      AppSnackbar.error(context, l10n.tdSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Material(
        color: context.colors.card,
        shape: const CircleBorder(),
        elevation: 1,
        child: IconButton(
          tooltip: _saved ? l10n.savedRemove : l10n.tdSave,
          onPressed: _toggle,
          icon: AnimatedSwitcher(
            duration: AppDurations.fast,
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              AppIcons.favorite,
              key: ValueKey(_saved),
              size: 20,
              fill: _saved ? 1 : 0,
              color: _saved ? context.palette.accentRose : context.scheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
