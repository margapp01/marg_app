import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../../profile/domain/entities/cms_content.dart';

/// "By signing in, you accept the Terms & Conditions and Privacy Policy." under
/// the sign-in button. Both names are links to the CMS pages (public route,
/// readable before sign-in). Word order comes from the l10n template, so the
/// Hindi sentence keeps its own grammar.
class LegalConsentText extends StatefulWidget {
  const LegalConsentText({super.key});

  @override
  State<LegalConsentText> createState() => _LegalConsentTextState();
}

class _LegalConsentTextState extends State<LegalConsentText> {
  // Unlikely-to-collide markers the l10n template is filled with, then split on.
  static const _termsMark = '\u{E000}T\u{E000}';
  static const _privacyMark = '\u{E000}P\u{E000}';

  late final TapGestureRecognizer _terms = TapGestureRecognizer()..onTap = () => _open(PageKind.terms);
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()..onTap = () => _open(PageKind.privacy);

  void _open(PageKind kind) {
    context.pushNamed(RouteNames.legalPage, pathParameters: {RoutePaths.staticPageKindParam: kind.name});
  }

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final base = context.textTheme.labelMedium?.copyWith(color: context.colors.textSecondary, height: 1.5);
    final link = base?.semiBold.copyWith(
      color: context.scheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: context.scheme.primary,
    );

    final spans = <InlineSpan>[];
    final template = l10n.siLegalConsent(_termsMark, _privacyMark);
    for (final part in template.split(RegExp('(?=$_termsMark|$_privacyMark)|(?<=$_termsMark|$_privacyMark)'))) {
      if (part == _termsMark) {
        spans.add(TextSpan(text: l10n.pfTerms, style: link, recognizer: _terms));
      } else if (part == _privacyMark) {
        spans.add(TextSpan(text: l10n.pfPrivacyPolicy, style: link, recognizer: _privacy));
      } else if (part.isNotEmpty) {
        spans.add(TextSpan(text: part));
      }
    }

    return Text.rich(TextSpan(style: base, children: spans), textAlign: TextAlign.center);
  }
}
