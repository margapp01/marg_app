import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../animations/animations.dart';
import '../badges/app_badge.dart';
import '../buttons/app_button.dart';
import '../cards/stat_ledger.dart';
import '../components/app_card.dart';
import '../dividers/app_divider.dart';
import '../images/illustrated_icon.dart';
import 'html_content_view.dart';

/// One `<h1>`/`<h2>` section of a CMS document: its heading and the blocks
/// under it, up to the next section.
class DocumentSection {
  const DocumentSection({required this.heading, required this.blocks, this.number});

  /// Plain heading text, without the number the CMS may have written into it.
  final String heading;

  /// The heading's own number ("4" of "4. Your rights"), when it has one.
  final String? number;
  final List<HtmlBlock> blocks;
}

final _headingNumber = RegExp(r'^([0-9\u0966-\u096F]+)[.)]\s+');

/// Splits parsed CMS HTML into the opening blocks before the first section
/// heading and the sections after it. Pure, so it can be unit-tested.
({List<HtmlBlock> intro, List<DocumentSection> sections}) splitDocument(List<HtmlBlock> blocks) {
  final intro = <HtmlBlock>[];
  final sections = <({String heading, String? number, List<HtmlBlock> blocks})>[];
  for (final b in blocks) {
    if (b.tag == 'h1' || b.tag == 'h2') {
      final text = htmlToPlainText(b.text);
      final number = _headingNumber.firstMatch(text);
      sections.add((
        heading: number == null ? text : text.substring(number.end),
        number: number?.group(1),
        blocks: <HtmlBlock>[],
      ));
    } else if (sections.isEmpty) {
      intro.add(b);
    } else {
      sections.last.blocks.add(b);
    }
  }
  return (
    intro: intro,
    sections: [for (final s in sections) DocumentSection(heading: s.heading, number: s.number, blocks: s.blocks)],
  );
}

/// A long CMS document — Privacy Policy, Terms, About — laid out for reading:
/// a header card (icon, title, last-updated date and reading time over the
/// opening paragraphs), an "On this page" list that jumps to each section,
/// numbered sections, and "Back to top" at the end. A page without section
/// headings reads as one block under the header.
class CmsDocumentView extends StatefulWidget {
  const CmsDocumentView({
    required this.title,
    required this.html,
    required this.icon,
    this.updatedAt,
    super.key,
  });

  final String title;
  final String html;
  final IconData icon;
  final DateTime? updatedAt;

  @override
  State<CmsDocumentView> createState() => _CmsDocumentViewState();
}

class _CmsDocumentViewState extends State<CmsDocumentView> {
  static const int _wordsPerMinute = 200;

  final ScrollController _scroll = ScrollController();
  late List<HtmlBlock> _intro;
  late List<DocumentSection> _sections;
  late List<GlobalKey> _sectionKeys;
  late int _readMinutes;

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(CmsDocumentView old) {
    super.didUpdateWidget(old);
    if (old.html != widget.html) _parse();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _parse() {
    final doc = splitDocument(parseHtmlBlocks(widget.html));
    _intro = doc.intro;
    _sections = doc.sections;
    _sectionKeys = [for (final _ in _sections) GlobalKey()];
    final words = htmlToPlainText(widget.html).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    _readMinutes = (words / _wordsPerMinute).ceil().clamp(1, 999);
  }

  Duration get _motion => MediaQuery.disableAnimationsOf(context) ? Duration.zero : AppDurations.slow;

  void _jumpTo(int index) {
    final target = _sectionKeys[index].currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target, duration: _motion, curve: AppCurves.standard);
  }

  void _backToTop() => _scroll.animateTo(0, duration: _motion, curve: AppCurves.standard);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSections = _sections.isNotEmpty;
    return Scrollbar(
      controller: _scroll,
      child: SingleChildScrollView(
        controller: _scroll,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxxl + context.viewPadding.bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  title: widget.title,
                  icon: widget.icon,
                  updatedAt: widget.updatedAt,
                  readMinutes: _readMinutes,
                  intro: hasSections ? _intro : const [],
                ).fadeIn(),
                if (_sections.length > 1) ...[
                  const Gap(AppSpacing.lg),
                  _Contents(sections: _sections, onOpen: _jumpTo).fadeIn(),
                ],
                const Gap(AppSpacing.xl),
                if (hasSections)
                  for (var i = 0; i < _sections.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: AppDivider(),
                      ),
                    _Section(key: _sectionKeys[i], number: _sections[i].number ?? '${i + 1}', section: _sections[i]),
                  ]
                else
                  HtmlContentView.blocks(_intro, textStyle: _bodyStyle(context)),
                if (_sections.length > 1) ...[
                  const Gap(AppSpacing.xxl),
                  Center(
                    child: AppButton.ghost(label: l10n.docBackToTop, icon: AppIcons.arrowUpward, onPressed: _backToTop),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _bodyStyle(BuildContext context) =>
    context.textTheme.bodyMedium!.copyWith(height: 1.65, color: context.scheme.onSurface);

/// Icon, title, "Last updated" and reading time on warm parchment, with the
/// document's opening paragraphs beneath a gold rule.
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.icon,
    required this.updatedAt,
    required this.readMinutes,
    required this.intro,
  });

  final String title;
  final IconData icon;
  final DateTime? updatedAt;
  final int readMinutes;
  final List<HtmlBlock> intro;

  static const double _iconSize = 52;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final updated = updatedAt;
    return AppCard(
      gradient: AppGradients.parchment,
      padding: AppSpacing.allXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IllustratedIcon(
            fallbackIcon: icon,
            color: context.scheme.primary,
            background: context.colors.card,
            size: _iconSize,
          ),
          const Gap(AppSpacing.md),
          Semantics(
            header: true,
            child: Text(title, style: context.displayText.headlineSmall.withColor(context.scheme.secondary)),
          ),
          const Gap(AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              if (updated != null)
                AppBadge(
                  label: l10n.pfLastUpdated(DateFormat.yMMMMd(lang).format(updated)),
                  icon: AppIcons.calendar,
                  tone: AppBadgeTone.primary,
                ),
              AppBadge(label: l10n.docReadTime(readMinutes), icon: AppIcons.timer),
            ],
          ),
          if (intro.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: GoldRule(),
            ),
            HtmlContentView.blocks(
              intro,
              textStyle: _bodyStyle(context).copyWith(color: context.colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// "On this page": the numbered section headings, each jumping to its section.
class _Contents extends StatelessWidget {
  const _Contents({required this.sections, required this.onOpen});

  final List<DocumentSection> sections;
  final ValueChanged<int> onOpen;

  static const double _rowHeight = 48;
  static const double _numberWidth = 32;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      variant: AppCardVariant.outlined,
      padding: EdgeInsets.zero,
      child: ExpandableSection(
        leading: IllustratedIcon(fallbackIcon: AppIcons.contents, color: context.scheme.primary, size: 36),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.docOnThisPage, style: context.textTheme.titleSmall?.semiBold),
            Text(l10n.docSections(sections.length), style: context.caption),
          ],
        ),
        child: Column(
          children: [
            for (var i = 0; i < sections.length; i++)
              InkWell(
                onTap: () => onOpen(i),
                borderRadius: AppRadius.mdAll,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _rowHeight),
                  child: Row(
                    children: [
                      SizedBox(
                        width: _numberWidth,
                        child: Text(
                          sections[i].number ?? '${i + 1}',
                          style: context.textTheme.labelMedium?.bold.withColor(context.scheme.primary),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Text(sections[i].heading, style: context.textTheme.bodyMedium),
                        ),
                      ),
                      Icon(AppIcons.chevronRight, size: 20, color: context.colors.textSecondary),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A numbered section: saffron number disc, heading, then its content
/// aligned under the heading.
class _Section extends StatelessWidget {
  const _Section({required this.number, required this.section, super.key});

  final String number;
  final DocumentSection section;

  static const double _discSize = 32;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: _discSize,
                height: _discSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.scheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(number, style: context.textTheme.labelLarge?.bold.withColor(context.scheme.primary)),
              ),
            ),
            const Gap.h(AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Semantics(
                  header: true,
                  child: Text(
                    section.heading,
                    style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.secondary),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (section.blocks.isNotEmpty) ...[
          const Gap(AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: _discSize + AppSpacing.md),
            child: HtmlContentView.blocks(section.blocks, textStyle: _bodyStyle(context)),
          ),
        ],
      ],
    );
  }
}
