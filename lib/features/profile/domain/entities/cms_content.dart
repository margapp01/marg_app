// Help & Support content from the CMS (`GET /cms/faqs`, `GET /cms/pages/:kind`).

String? _s(Object? v) => v is String && v.isNotEmpty ? v : null;

class Faq {
  const Faq({required this.question, required this.answer, this.category});
  final String question;
  final String answer;
  final String? category;

  factory Faq.fromJson(Map<String, dynamic> j) => Faq(
        question: _s(j['question']) ?? '',
        answer: _s(j['answer']) ?? '',
        category: _s(j['category']),
      );
}

/// A CMS static page (ABOUT / CONTACT / PRIVACY / TERMS / …). `contentHtml` is
/// rendered as plain text (tags stripped) — no HTML dependency is introduced.
class StaticPage {
  const StaticPage({required this.title, required this.contentHtml, this.titleHi, this.contentHtmlHi, this.updatedAt});
  final String title;
  final String contentHtml;

  /// Hindi version from the CMS; null when the page has none.
  final String? titleHi;
  final String? contentHtmlHi;

  /// Last CMS update; legal pages take effect from this date.
  final DateTime? updatedAt;

  /// The page in [languageCode] — Hindi only when a Hindi version exists,
  /// otherwise the English page.
  StaticPage localized(String languageCode) {
    final hi = contentHtmlHi;
    if (languageCode != 'hi' || hi == null) return this;
    return StaticPage(title: titleHi ?? title, contentHtml: hi, updatedAt: updatedAt);
  }

  /// A best-effort plain-text rendering of the stored HTML.
  String get plainText => contentHtml
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(p|div|h[1-6]|li)>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

  factory StaticPage.fromJson(Map<String, dynamic> j) => StaticPage(
        title: _s(j['title']) ?? '',
        contentHtml: (j['contentHtml'] as String?) ?? '',
        titleHi: _s(j['titleHi']),
        contentHtmlHi: _s((j['contentHtmlHi'] as String?)?.trim()),
        updatedAt: DateTime.tryParse(_s(j['updatedAt']) ?? '')?.toLocal(),
      );
}

/// Backend `PageKind` values used by Help & Support.
enum PageKind { about, contact, privacy, terms }

extension PageKindWire on PageKind {
  String get wire => switch (this) {
        PageKind.about => 'ABOUT',
        PageKind.contact => 'CONTACT',
        PageKind.privacy => 'PRIVACY',
        PageKind.terms => 'TERMS',
      };
}
