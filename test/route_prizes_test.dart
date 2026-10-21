import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/features/routes/domain/entities/yatra_route.dart';

void main() {
  test('a route reads its admin-set completion prizes', () {
    final route = YatraRoute.fromJson(const {
      'id': 'r1', 'name': '12 Jyotirlinga Yatra', 'slug': '12-jyotirlinga-yatra', 'type': 'JYOTIRLINGA', 'templeCount': 12,
      'completionRewards': ['TSHIRT', 'RECHARGE'], 'rechargeMonths': 6, 'rechargeMaxInr': 1500,
    });
    expect(route.prizes.tshirt, isTrue);
    expect(route.prizes.recharge, isTrue);
    expect(route.prizes.rechargeMonths, 6);
    expect(route.prizes.rechargeMaxInr, 1500);
  });

  test('one prize, none, or an older server without the fields', () {
    final tee = RoutePrizes.fromJson(const {'completionRewards': ['TSHIRT']});
    expect((tee.tshirt, tee.recharge, tee.rechargeMonths, tee.rechargeMaxInr), (true, false, 3, 1000));
    expect(RoutePrizes.fromJson(const {'completionRewards': <String>[]}).isEmpty, isTrue);
    expect(RoutePrizes.fromJson(const {}).isEmpty, isTrue);
    expect(RoutePrizes.fromJson(const {'completionRewards': ['CAR']}).isEmpty, isTrue);
  });
}
