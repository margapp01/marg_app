import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/constants/app_constants.dart';
import 'package:marg_app/core/utils/age.dart';

void main() {
  final now = DateTime(2026, 10, 13);

  test('the minimum account age is 18 until guardian consent ships', () {
    expect(AppConstants.minAccountAge, 18);
  });

  test('turns 18 exactly on the 18th birthday', () {
    expect(isAtLeastAge(DateTime(2008, 10, 13), 18, now: now), isTrue);
    expect(isAtLeastAge(DateTime(2008, 10, 14), 18, now: now), isFalse);
  });

  test('a 29 February birthday counts from 1 March in a non-leap year', () {
    expect(isAtLeastAge(DateTime(2008, 2, 29), 18, now: DateTime(2026, 3, 1)), isTrue);
    expect(isAtLeastAge(DateTime(2008, 2, 29), 18, now: DateTime(2026, 2, 28)), isFalse);
  });
}
