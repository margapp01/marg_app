// Domain models for `GET /search` (grouped global search). Hand-written
// parsing matches the app's model convention (see AuthUser / HomeDashboard).

/// A searchable entity type. Mirrors the backend `SearchHit.type` union
/// exactly; anything unrecognised parses to [unknown].
enum SearchType {
  temple,
  route,
  city,
  festival,
  card,
  achievement,
  blog,
  faq,
  page,
  unknown;

  static SearchType fromWire(String? v) {
    switch (v) {
      case 'temple':
        return SearchType.temple;
      case 'route':
        return SearchType.route;
      case 'city':
        return SearchType.city;
      case 'festival':
        return SearchType.festival;
      case 'card':
        return SearchType.card;
      case 'achievement':
        return SearchType.achievement;
      case 'blog':
        return SearchType.blog;
      case 'faq':
        return SearchType.faq;
      case 'page':
        return SearchType.page;
      default:
        return SearchType.unknown;
    }
  }
}

/// The "Search In" scope chips. `all` sends no `types` filter.
enum SearchScope {
  all(null),
  temples('temples'),
  routes('routes'),
  festivals('festivals'),
  blogs('blogs'),
  faqs('faqs'),
  pages('pages');

  const SearchScope(this.wireType);

  /// Backend `types` value, or null for "All".
  final String? wireType;
}

/// Sort options the `/search` contract can honestly support: server relevance
/// order, or a client-side A–Z. (Distance/popularity/newest need fields the
/// search contract doesn't return — intentionally omitted.)
enum SearchSort { relevance, alphabetical }

class SearchFilter {
  const SearchFilter({this.scope = SearchScope.all, this.sort = SearchSort.relevance});

  final SearchScope scope;
  final SearchSort sort;

  SearchFilter copyWith({SearchScope? scope, SearchSort? sort}) =>
      SearchFilter(scope: scope ?? this.scope, sort: sort ?? this.sort);

  bool get isDefault => scope == SearchScope.all && sort == SearchSort.relevance;
}

class SearchHit {
  const SearchHit({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.slug,
    this.imageUrl,
  });

  final SearchType type;
  final String id;
  final String title;
  final String? subtitle;
  final String? slug;
  final String? imageUrl;

  factory SearchHit.fromJson(Map<String, dynamic> j) => SearchHit(
        type: SearchType.fromWire(j['type'] as String?),
        id: (j['id'] as String?) ?? '',
        title: (j['title'] as String?) ?? '',
        subtitle: j['subtitle'] as String?,
        slug: j['slug'] as String?,
        imageUrl: j['imageUrl'] as String?,
      );
}

/// One rendered result group (e.g. all temple hits).
class SearchGroup {
  const SearchGroup(this.type, this.hits);

  final SearchType type;
  final List<SearchHit> hits;
}

class SearchResults {
  const SearchResults({required this.query, required this.total, required this.groups});

  final String query;
  final int total;

  /// Non-empty groups in display order.
  final List<SearchGroup> groups;

  bool get isEmpty => total == 0;

  static List<SearchHit> _list(Object? v) => v is List
      ? v
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => SearchHit.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false)
      : const [];

  /// Parses the envelope's `data` and applies client-side [sort].
  factory SearchResults.fromJson(Map<String, dynamic> json, {SearchSort sort = SearchSort.relevance}) {
    final r = (json['results'] as Map?)?.cast<String, dynamic>() ?? const {};
    // Display order matches the design (temples first, pages last); places
    // sit beside temples so "Ujjain" reads as a place to explore.
    const order = <(SearchType, String)>[
      (SearchType.temple, 'temples'),
      (SearchType.city, 'cities'),
      (SearchType.route, 'routes'),
      (SearchType.festival, 'festivals'),
      (SearchType.card, 'cards'),
      (SearchType.achievement, 'achievements'),
      (SearchType.blog, 'blogs'),
      (SearchType.faq, 'faqs'),
      (SearchType.page, 'pages'),
    ];

    final groups = <SearchGroup>[];
    for (final (type, key) in order) {
      var hits = _list(r[key]);
      if (hits.isEmpty) continue;
      if (sort == SearchSort.alphabetical) {
        hits = [...hits]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      }
      groups.add(SearchGroup(type, hits));
    }

    final total = groups.fold<int>(0, (n, g) => n + g.hits.length);
    return SearchResults(
      query: (json['query'] as String?) ?? '',
      total: total,
      groups: groups,
    );
  }
}
