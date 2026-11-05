import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/features/temple_detail/domain/entities/temple_detail.dart';

void main() {
  TempleTiming t(int day, String open, String close) => TempleTiming(dayOfWeek: day, openTime: open, closeTime: close);

  // Tuesday 3 Nov 2026 (day 2), with a midday break; closed on Wednesday (day 3).
  final timings = [
    for (final d in [0, 1, 2, 4, 5, 6]) ...[t(d, '06:00', '12:00'), t(d, '16:00', '21:00')],
  ];
  DateTime at(int h, int m) => DateTime(2026, 11, 3, h, m);

  test('open: counts down to the close', () {
    final c = timings.nextChange(at(9, 15))!;
    expect((c.open, c.tomorrow, c.at, c.minutes), (true, false, '12:00', 165));
  });

  test('in the break: counts down to the next session', () {
    final c = timings.nextChange(at(14, 20))!;
    expect((c.open, c.tomorrow, c.at, c.minutes), (false, false, '16:00', 100));
  });

  test('after the last session: no session tomorrow means no change line', () {
    expect(timings.nextChange(at(22, 0)), isNull);
  });

  test('after the last session: opens tomorrow when tomorrow has hours', () {
    final c = timings.nextChange(DateTime(2026, 11, 2, 22, 0))!; // Monday
    expect((c.open, c.tomorrow, c.at, c.minutes), (false, true, '06:00', null));
  });

  test('day spans as fractions, split past midnight', () {
    expect(timings.daySpans(2), [(0.25, 0.5), (16 / 24, 21 / 24)]);
    expect([t(5, '22:00', '02:00')].daySpans(5), [(22 / 24, 1.0), (0.0, 2 / 24)]);
  });

  test('closed days', () {
    expect(timings.closedDays, [3]);
  });
}
