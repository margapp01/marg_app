import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/features/cards/data/datasource/cards_remote_datasource.dart';
import 'package:marg_app/features/cards/data/repository/cards_repository_impl.dart';
import 'package:marg_app/features/cards/domain/entities/sacred_card.dart';

/// Serves the catalog card and the passport ownership map; the owned-detail
/// endpoint only knows user-card ids (as the backend does).
class _FakeRemote extends CardsRemoteDataSource {
  _FakeRemote({required this.owned}) : super(Dio());

  final Map<String, CardOwnership> owned;

  @override
  Future<SacredCard> catalogDetail(String id) async {
    if (id != 'card-1') throw DioException(requestOptions: RequestOptions(path: '/cards/$id'));
    return const SacredCard(id: 'card-1', title: 'Kedarnath', imageUrl: '', rarity: 'EPIC');
  }

  @override
  Future<Map<String, CardOwnership>> ownedCards() async => owned;

  @override
  Future<SacredCard> myCardDetail(String id) async {
    if (id != 'uc-1') throw DioException(requestOptions: RequestOptions(path: '/my/cards/$id'));
    return const SacredCard(id: 'card-1', title: 'Kedarnath', imageUrl: '', rarity: 'EPIC', owned: true);
  }
}

void main() {
  final unlockedAt = DateTime.utc(2026, 9, 1);

  test('a collected card opened by its catalog id is owned, with its unlock details', () async {
    final repo = CardsRepositoryImpl(_FakeRemote(owned: {
      'card-1': CardOwnership(userCardId: 'uc-1', mintNumber: 7, unlockedAt: unlockedAt),
    }));

    final card = await repo.cardDetail('card-1');

    expect(card.owned, isTrue);
    expect(card.ownership?.userCardId, 'uc-1');
    expect(card.ownership?.mintNumber, 7);
    expect(card.ownership?.unlockedAt, unlockedAt);
  });

  test('an uncollected card stays locked', () async {
    final repo = CardsRepositoryImpl(_FakeRemote(owned: const {}));

    final card = await repo.cardDetail('card-1');

    expect(card.owned, isFalse);
    expect(card.ownership, isNull);
  });

  test('a user-card id still resolves through the collection', () async {
    final repo = CardsRepositoryImpl(_FakeRemote(owned: const {}));

    final card = await repo.cardDetail('uc-1');

    expect(card.owned, isTrue);
  });
}
