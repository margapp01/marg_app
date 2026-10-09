import 'sacred_card.dart';

/// A page of cards plus enough pagination info to drive infinite scroll.
class CardPage {
  const CardPage({required this.items, required this.page, required this.totalPages});

  final List<SacredCard> items;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;

  static const empty = CardPage(items: [], page: 1, totalPages: 1);
}
