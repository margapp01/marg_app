import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../images/images.dart';

/// One parsed block of CMS HTML. Kept deliberately small — the CMS authors
/// block-level content (headings, paragraphs, lists, quotes, images, rules),
/// and this is the vocabulary the renderer understands.
class HtmlBlock {
  const HtmlBlock(this.tag, {this.text = '', this.items = const [], this.src});

  /// `h1`|`h2`|`h3`|`p`|`ul`|`ol`|`blockquote`|`img`|`hr`.
  final String tag;

  /// Inner HTML (still carries inline `<b>/<i>/<a>` for text blocks).
  final String text;

  /// Inner HTML of each `<li>` (list blocks only).
  final List<String> items;

  /// Absolute image URL (`img` blocks only).
  final String? src;
}

final _blockPattern = RegExp(
  r'<h([1-6])[^>]*>(.*?)</h\1>'
  r'|<p[^>]*>(.*?)</p>'
  r'|<ul[^>]*>(.*?)</ul>'
  r'|<ol[^>]*>(.*?)</ol>'
  r'|<blockquote[^>]*>(.*?)</blockquote>'
  r'|<img[^>]*?src="([^"]*)"[^>]*?>'
  r'|<hr\s*/?>',
  dotAll: true,
  caseSensitive: false,
);

final _liPattern = RegExp(r'<li[^>]*>(.*?)</li>', dotAll: true, caseSensitive: false);

/// Parses CMS HTML into an ordered list of [HtmlBlock]s. Pure + side-effect
/// free so it can be unit-tested. Anything the CMS emits that isn't a
/// recognised block is folded into a trailing paragraph so no text is lost.
List<HtmlBlock> parseHtmlBlocks(String html) {
  if (html.trim().isEmpty) return const [];
  final blocks = <HtmlBlock>[];
  var cursor = 0;

  void flushText(String raw) {
    final stripped = _stripTags(raw).trim();
    if (stripped.isNotEmpty) blocks.add(HtmlBlock('p', text: raw.trim()));
  }

  for (final m in _blockPattern.allMatches(html)) {
    if (m.start > cursor) flushText(html.substring(cursor, m.start));
    cursor = m.end;

    if (m.group(1) != null) {
      final level = int.parse(m.group(1)!);
      blocks.add(HtmlBlock('h${level.clamp(1, 3)}', text: m.group(2)!.trim()));
    } else if (m.group(3) != null) {
      blocks.add(HtmlBlock('p', text: m.group(3)!.trim()));
    } else if (m.group(4) != null) {
      blocks.add(HtmlBlock('ul', items: _items(m.group(4)!)));
    } else if (m.group(5) != null) {
      blocks.add(HtmlBlock('ol', items: _items(m.group(5)!)));
    } else if (m.group(6) != null) {
      blocks.add(HtmlBlock('blockquote', text: m.group(6)!.trim()));
    } else if (m.group(7) != null) {
      blocks.add(HtmlBlock('img', src: m.group(7)));
    } else {
      blocks.add(const HtmlBlock('hr'));
    }
  }
  if (cursor < html.length) flushText(html.substring(cursor));
  return blocks;
}

List<String> _items(String listHtml) =>
    _liPattern.allMatches(listHtml).map((m) => m.group(1)!.trim()).where((s) => _stripTags(s).trim().isNotEmpty).toList();

String _stripTags(String s) => s.replaceAll(RegExp(r'<[^>]+>'), '');

String _decode(String s) => s
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&rsquo;', '’')
    .replaceAll('&lsquo;', '‘')
    .replaceAll('&mdash;', '—')
    .replaceAll('&hellip;', '…');

final _inlinePattern = RegExp(
  r'<(strong|b)>(.*?)</\1>'
  r'|<(em|i)>(.*?)</\3>'
  r'|<a[^>]*?href="([^"]*)"[^>]*?>(.*?)</a>'
  r'|<br\s*/?>',
  dotAll: true,
  caseSensitive: false,
);

/// Renders admin-authored CMS HTML using **only** the design system — no third
/// party HTML dependency, no hardcoded type. Supports headings, paragraphs,
/// ordered/unordered lists, blockquotes, images, rules, and inline
/// bold / italic / links. Reused by Blog Detail and the Static Pages screens.
class HtmlContentView extends StatelessWidget {
  const HtmlContentView({required this.html, this.textStyle, super.key});

  final String html;

  /// Base paragraph style; defaults to `bodyLarge` with comfortable line height.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final blocks = parseHtmlBlocks(html);
    if (blocks.isEmpty) {
      return Text(
        _decode(_stripTags(html)).trim(),
        style: textStyle ?? context.textTheme.bodyLarge?.copyWith(height: 1.6),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.md),
            child: _block(context, blocks[i]),
          ),
      ],
    );
  }

  Widget _block(BuildContext context, HtmlBlock b) {
    final base = textStyle ?? context.textTheme.bodyLarge!.copyWith(height: 1.6);
    switch (b.tag) {
      case 'h1':
        return _RichLine(html: b.text, style: context.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w700));
      case 'h2':
        return _RichLine(html: b.text, style: context.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700));
      case 'h3':
        return _RichLine(html: b.text, style: context.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600));
      case 'ul':
      case 'ol':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < b.items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: AppSpacing.sm),
                      child: Text(
                        b.tag == 'ol' ? '${i + 1}.' : '•',
                        style: base.copyWith(color: context.scheme.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(child: _RichLine(html: b.items[i], style: base)),
                  ],
                ),
              ),
          ],
        );
      case 'blockquote':
        return Container(
          width: double.infinity,
          padding: AppSpacing.allMd,
          decoration: BoxDecoration(
            color: context.scheme.primary.withValues(alpha: 0.06),
            borderRadius: AppRadius.mdAll,
            border: Border(left: BorderSide(color: context.scheme.primary, width: 3)),
          ),
          child: _RichLine(
            html: b.text,
            style: base.copyWith(fontStyle: FontStyle.italic, color: context.colors.textSecondary),
          ),
        );
      case 'img':
        return ClipRRect(
          borderRadius: AppRadius.mdAll,
          child: AppNetworkImage(url: b.src ?? '', width: double.infinity, fit: BoxFit.cover),
        );
      case 'hr':
        return Divider(color: context.colors.border, height: AppSpacing.lg);
      default:
        return _RichLine(html: b.text, style: base);
    }
  }
}

/// A single run of inline HTML (bold / italic / links) rendered as one
/// [Text.rich]. Falls back to plain decoded text for anything it can't parse.
class _RichLine extends StatelessWidget {
  const _RichLine({required this.html, required this.style});
  final String html;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: _spans(context, html, style)));
  }

  List<InlineSpan> _spans(BuildContext context, String input, TextStyle style) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    void plain(String raw) {
      final t = _decode(_stripTags(raw));
      if (t.isNotEmpty) spans.add(TextSpan(text: t, style: style));
    }

    for (final m in _inlinePattern.allMatches(input)) {
      if (m.start > cursor) plain(input.substring(cursor, m.start));
      cursor = m.end;
      if (m.group(2) != null) {
        spans.addAll(_spans(context, m.group(2)!, style.copyWith(fontWeight: FontWeight.w700)));
      } else if (m.group(4) != null) {
        spans.addAll(_spans(context, m.group(4)!, style.copyWith(fontStyle: FontStyle.italic)));
      } else if (m.group(6) != null) {
        final href = m.group(5)!;
        spans.add(TextSpan(
          text: _decode(_stripTags(m.group(6)!)),
          style: style.copyWith(color: context.scheme.primary, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              final uri = Uri.tryParse(href);
              if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
            },
        ));
      } else {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    if (cursor < input.length) plain(input.substring(cursor));
    return spans.isEmpty ? [TextSpan(text: _decode(_stripTags(input)), style: style)] : spans;
  }
}
