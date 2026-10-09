import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../animations/app_entrance.dart';
import '../dividers/app_divider.dart';
import 'state_art.dart';

/// Shared body of [EmptyView] and [ErrorView]: an illustrated scene (or a
/// tinted icon badge when no scene fits), the title, an optional message and
/// an optional action — centred, animated in, and scrollable so it never
/// overflows in short spaces (landscape, keyboard open, inside tabs).
class StateLayout extends StatelessWidget {
  const StateLayout({
    required this.title,
    required this.icon,
    required this.accent,
    this.art,
    this.message,
    this.action,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Color accent;
  final StateArt? art;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final illustrated = art != null;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (illustrated)
                StateArtImage(art!)
              else
                Container(
                  padding: AppSpacing.allLg,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 40, color: accent),
                ),
              const Gap(AppSpacing.lg),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: illustrated ? context.displayText.headlineSmall : context.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              if (illustrated) ...[
                const Gap(AppSpacing.sm),
                const LotusRule(),
              ],
              if (message != null) ...[
                const Gap(AppSpacing.sm),
                Text(
                  message!,
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, height: 1.45),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const Gap(AppSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
