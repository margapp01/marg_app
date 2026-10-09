import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../core/media/picked_photo.dart';
import '../../../../../shared/design_system.dart';
import 'setup_common.dart';

/// One line of the review card: an icon and the devotee's answer (null when
/// they skipped it).
typedef ReviewRow = ({IconData icon, String? value});

/// Step 5 — "Almost Done!": everything the devotee entered, for a last look
/// before "Complete Setup" saves it.
class ReviewStep extends StatelessWidget {
  const ReviewStep({
    required this.name,
    required this.email,
    required this.rows,
    this.photoUrl,
    this.pickedPhoto,
    super.key,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final PickedPhoto? pickedPhoto;
  final List<ReviewRow> rows;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: AppSpacing.screenAll,
      children: [
        SetupHeader(title: l10n.suReviewTitle, subtitle: l10n.suReviewSubtitle),
        const Gap(AppSpacing.xl),
        AppCard(
          padding: AppSpacing.allLg,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.gold, width: 2),
                ),
                child: pickedPhoto != null
                    ? ClipOval(
                        child: Image.memory(pickedPhoto!.bytes, width: 88, height: 88, fit: BoxFit.cover),
                      )
                    : AppAvatar(imageUrl: photoUrl, name: name, radius: 44),
              ),
              const Gap(AppSpacing.sm),
              Text(name, textAlign: TextAlign.center, style: context.displayText.titleLarge),
              if (email.isNotEmpty)
                Text(email, style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary)),
              const Gap(AppSpacing.md),
              for (final row in rows) ...[
                const AppDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(row.icon, size: 20, color: context.scheme.primary),
                      const Gap.h(AppSpacing.md),
                      Expanded(
                        child: Text(
                          row.value ?? l10n.suNotProvided,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: row.value == null ? context.colors.textDisabled : context.scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const Gap(AppSpacing.md),
        Text(
          l10n.suUpdateLater,
          textAlign: TextAlign.center,
          style: context.textTheme.labelMedium?.copyWith(color: context.colors.textSecondary),
        ),
      ],
    );
  }
}
