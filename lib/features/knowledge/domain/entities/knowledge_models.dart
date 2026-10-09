// Knowledge Hub content models. Blog / Announcement / Banner are new to this
// feature; Festival, Quote, Faq and StaticPage are REUSED from the notifications
// and profile features (composed from the same CMS endpoints) — never
// re-modelled here, to avoid duplicating business logic.

export 'package:marg_app/features/notifications/domain/entities/hub_content.dart' show Festival, Quote;
export 'package:marg_app/features/profile/domain/entities/cms_content.dart' show Faq, StaticPage, PageKind, PageKindWire;

String? _s(Object? v) => v is String && v.isNotEmpty ? v : null;
DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// A blog article (`GET /cms/blogs`, `GET /cms/blogs/:slug`).
///
/// The backend `Blog` has no author / reading-time / view-count columns, so
/// those are never surfaced except [readingMinutes], which is an honest
/// client-side estimate derived from the article body.
class Blog {
  const Blog({
    required this.id,
    required this.title,
    required this.slug,
    this.category,
    this.tags = const [],
    this.coverImageUrl,
    this.excerpt,
    this.contentHtml = '',
    this.publishedAt,
  });

  final String id;
  final String title;
  final String slug;
  final String? category;
  final List<String> tags;
  final String? coverImageUrl;
  final String? excerpt;
  final String contentHtml;
  final DateTime? publishedAt;

  /// Estimated read time from the body's word count (~200 wpm), min 1 minute.
  /// Falls back to the excerpt when the list payload has no body.
  int get readingMinutes {
    final source = contentHtml.isNotEmpty ? contentHtml : (excerpt ?? '');
    final text = source.replaceAll(RegExp(r'<[^>]+>'), ' ').trim();
    if (text.isEmpty) return 1;
    final words = text.split(RegExp(r'\s+')).length;
    return (words / 200).ceil().clamp(1, 99);
  }

  factory Blog.fromJson(Map<String, dynamic> j) => Blog(
        id: _s(j['id']) ?? '',
        title: _s(j['title']) ?? '',
        slug: _s(j['slug']) ?? '',
        category: _s(j['category']),
        tags: (j['tags'] as List?)?.whereType<String>().toList(growable: false) ?? const [],
        coverImageUrl: _s(j['coverImageUrl']),
        excerpt: _s(j['excerpt']),
        contentHtml: (j['contentHtml'] as String?) ?? '',
        publishedAt: _dt(j['publishAt']) ?? _dt(j['createdAt']),
      );
}

/// Backend `AnnouncementKind`.
enum AnnouncementKind { news, maintenance, festival, emergency, unknown }

AnnouncementKind announcementKindFromWire(String? wire) => switch (wire?.toUpperCase()) {
      'NEWS' => AnnouncementKind.news,
      'MAINTENANCE' => AnnouncementKind.maintenance,
      'FESTIVAL' => AnnouncementKind.festival,
      'EMERGENCY' => AnnouncementKind.emergency,
      _ => AnnouncementKind.unknown,
    };

/// An announcement (`GET /cms/announcements`). Backend order is pinned-first,
/// then newest, which the datasource preserves.
class Announcement {
  const Announcement({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.pinned = false,
    this.createdAt,
  });

  final String id;
  final AnnouncementKind kind;
  final String title;
  final String body;
  final bool pinned;
  final DateTime? createdAt;

  factory Announcement.fromJson(Map<String, dynamic> j) => Announcement(
        id: _s(j['id']) ?? '',
        kind: announcementKindFromWire(_s(j['kind'])),
        title: _s(j['title']) ?? '',
        body: _s(j['body']) ?? '',
        pinned: j['pinned'] == true,
        createdAt: _dt(j['createdAt']),
      );
}

/// A promotional banner (`GET /cms/banners`) — used for the hub hero.
class KnowledgeBanner {
  const KnowledgeBanner({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.ctaLabel,
    this.ctaUrl,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? ctaLabel;
  final String? ctaUrl;

  factory KnowledgeBanner.fromJson(Map<String, dynamic> j) => KnowledgeBanner(
        id: _s(j['id']) ?? '',
        title: _s(j['title']) ?? '',
        subtitle: _s(j['subtitle']),
        imageUrl: _s(j['imageUrl']),
        ctaLabel: _s(j['ctaLabel']),
        ctaUrl: _s(j['ctaUrl']),
      );
}
