/// The kind of journey event (drives icon + colour in the timeline).
enum TimelineEventType { visit, card, achievement, route, milestone }

/// One entry in the merged Spiritual Journey timeline. Composed client-side
/// from visits + card unlocks + achievements + route completions.
class TimelineEvent {
  const TimelineEvent({
    required this.type,
    required this.title,
    required this.date,
    this.subtitle,
    this.points,
    this.imageUrl,
    this.slug,
  });

  final TimelineEventType type;
  final String title;
  final DateTime date;
  final String? subtitle;
  final int? points;
  final String? imageUrl;

  /// Temple slug for visits, route slug for routes — where a tap leads.
  final String? slug;
}
