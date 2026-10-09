import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/cms_content.dart';
import '../controllers/profile_controllers.dart';

final _appVersionProvider = FutureProvider.autoDispose<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  } catch (_) {
    return '';
  }
});

/// Screen 9 — Help & Support. FAQs + CMS static pages + version, licenses,
/// contact and rate. Reuses the CMS content endpoints.
class HelpSupportPage extends ConsumerWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final faqs = ref.watch(faqsProvider);
    final version = ref.watch(_appVersionProvider).valueOrNull ?? '';
    final p = context.palette;

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.pfHelpSupport)),
      body: ListView(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IntroBanner(icon: AppIcons.support, title: l10n.pfHelpHeroTitle, message: l10n.pfHelpHeroBody).fadeIn(),
                const Gap(AppSpacing.xl),
                faqs.when(
                  loading: () => const SkeletonBox(height: _faqSkeletonHeight, radius: AppRadius.card),
                  error: (_, _) => SettingsGroup(
                    title: l10n.pfFaqs,
                    children: [AppListTile(leadingIcon: AppIcons.info, iconColor: p.accentRose, title: l10n.pfErrorBody)],
                  ),
                  data: (list) => SettingsGroup(
                    title: l10n.pfFaqs,
                    dividerIndent: AppSpacing.lg,
                    children: list.isEmpty
                        ? [AppListTile(leadingIcon: AppIcons.help, iconColor: p.accentBlue, title: l10n.pfNoFaqs)]
                        : [for (final f in list.take(8)) _FaqTile(faq: f)],
                  ),
                ).fadeIn(delay: 40.ms),
                const Gap(AppSpacing.xl),
                SettingsGroup(
                  title: l10n.pfGroupSupport,
                  children: [
                    SettingsTile.navigation(icon: AppIcons.mail, iconColor: p.accentSaffron, title: l10n.pfContactSupport, subtitle: l10n.pfContactSupportHint, onTap: _contact),
                    SettingsTile.navigation(icon: AppIcons.shield, iconColor: p.accentViolet, title: l10n.pfPrivacyPolicy, onTap: () => _page(context, PageKind.privacy)),
                    SettingsTile.navigation(icon: AppIcons.description, iconColor: p.accentBlue, title: l10n.pfTerms, onTap: () => _page(context, PageKind.terms)),
                    SettingsTile.navigation(icon: AppIcons.info, iconColor: p.accentAmber, title: l10n.pfAbout, subtitle: version.isEmpty ? null : '${l10n.pfVersion} $version', onTap: () => _page(context, PageKind.about)),
                    SettingsTile.navigation(icon: AppIcons.star, iconColor: p.accentRose, title: l10n.pfRateApp, subtitle: l10n.pfRateAppHint, onTap: _rate),
                  ],
                ).fadeIn(delay: 80.ms),
              ],
            ),
          ),
          const Gap(AppSpacing.xl),
          _BrandFooter(version: version),
        ],
      ),
    );
  }

  static const double _faqSkeletonHeight = 180;

  void _page(BuildContext context, PageKind kind) =>
      context.pushNamed(RouteNames.profileStaticPage, pathParameters: {RoutePaths.staticPageKindParam: kind.name});

  Future<void> _contact() async {
    final uri = Uri(scheme: 'mailto', path: 'info@margapp.in', queryParameters: {'subject': 'MARG Support'});
    await launchUrl(uri);
  }

  Future<void> _rate() async {
    final uri = Uri.parse('https://play.google.com/store/apps/details?id=in.margapp.marg');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});
  final Faq faq;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
        iconColor: context.scheme.primary,
        collapsedIconColor: context.colors.textSecondary,
        title: Text(faq.question, style: context.textTheme.bodyMedium?.semiBold),
        children: [Align(alignment: Alignment.centerLeft, child: Text(faq.answer, style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary, height: 1.5)))],
      ),
    );
  }
}

/// MARG's mark, tagline and version over the temple skyline — the quiet
/// sign-off at the foot of Help & Support.
class _BrandFooter extends StatelessWidget {
  const _BrandFooter({required this.version});
  final String version;

  static const double _logoHeight = 56;
  static const double _skylineHeight = 120;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = context.caption.copyWith(color: context.colors.textSecondary);
    return Column(
      children: [
        Image.asset(BrandAssets.logoMark, height: _logoHeight, excludeFromSemantics: true, errorBuilder: (_, _, _) => const SizedBox.shrink()),
        const Gap(AppSpacing.xs),
        Text(l10n.acBrandTagline, style: muted, textAlign: TextAlign.center),
        if (version.isNotEmpty) Text('${l10n.pfVersion} $version', style: muted),
        const Gap(AppSpacing.md),
        Image.asset(
          BrandAssets.skylineLineArt,
          height: _skylineHeight,
          width: double.infinity,
          excludeFromSemantics: true,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          opacity: const AlwaysStoppedAnimation(0.35),
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
