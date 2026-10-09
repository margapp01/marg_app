// Festival + Quote models for the Activity Hub tabs (`/festivals/*`, `/quotes/*`).

String? _s(Object? v) => v is String && v.isNotEmpty ? v : null;
DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// A festival (`GET /festivals/upcoming` / `/festivals/:slug`).
class Festival {
  const Festival({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.deity,
    this.imageUrl,
    this.scope,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? deity;
  final String? imageUrl;
  final String? scope;
  final DateTime? startDate;
  final DateTime? endDate;

  /// Whole days until the festival starts (0 = today, negative = under way).
  int? get daysUntil {
    final d = startDate;
    if (d == null) return null;
    final now = DateTime.now();
    final start = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    return start.difference(today).inDays;
  }

  bool get isToday {
    final n = daysUntil;
    if (n != null && n == 0) return true;
    // Multi-day festival currently under way.
    final s = startDate, e = endDate;
    if (s == null) return false;
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final start = DateTime(s.year, s.month, s.day);
    final end = e == null ? start : DateTime(e.year, e.month, e.day);
    return !now.isBefore(start) && !now.isAfter(end);
  }

  factory Festival.fromJson(Map<String, dynamic> j) => Festival(
        id: _s(j['id']) ?? '',
        name: _s(j['name']) ?? '',
        slug: _s(j['slug']) ?? '',
        description: _s(j['description']),
        deity: _s(j['deity']),
        imageUrl: _s(j['imageUrl']),
        scope: _s(j['scope']),
        startDate: _dt(j['startDate']),
        endDate: _dt(j['endDate']),
      );
}

/// A quote (`GET /quotes/daily` / `/quotes`).
class Quote {
  const Quote({required this.id, required this.text, this.textHi, this.author, this.source, this.reference});

  final String id;
  final String text;
  final String? textHi;
  final String? author;
  final String? source;
  final String? reference;

  /// A friendly attribution line, e.g. "Bhagavad Gita (4.39)".
  String get attribution {
    final src = source == null ? null : _sourceLabel(source!);
    final parts = [src ?? author, if (reference != null && reference!.isNotEmpty) '($reference)'];
    return parts.whereType<String>().where((e) => e.isNotEmpty).join(' ');
  }

  static String _sourceLabel(String wire) {
    switch (wire.toUpperCase()) {
      case 'BHAGAVAD_GITA':
        return 'Bhagavad Gita';
      case 'UPANISHADS':
        return 'Upanishads';
      case 'VEDAS':
        return 'Vedas';
      case 'RAMAYANA':
        return 'Ramayana';
      case 'MAHABHARATA':
        return 'Mahabharata';
      default:
        return wire.replaceAll('_', ' ');
    }
  }

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
        id: _s(j['id']) ?? '',
        text: _s(j['text']) ?? '',
        textHi: _s(j['textHi']),
        author: _s(j['author']),
        source: _s(j['source']),
        reference: _s(j['reference']),
      );
}
