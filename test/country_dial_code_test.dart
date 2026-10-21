import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/core/models/country_dial_code.dart';

void main() {
  test('India takes exactly 10 digits and builds E.164', () {
    const india = CountryDialCode.india;
    expect(india.accepts('9876543210'), isTrue);
    expect(india.accepts('987654321'), isFalse);
    expect(india.e164('9876543210'), '+919876543210');
    expect(india.flag, '🇮🇳');
  });

  test('every country fits the API range (8–15 digits in total)', () {
    for (final c in CountryDialCode.all) {
      expect(c.dialCode.length + c.minDigits, greaterThanOrEqualTo(8), reason: c.name);
      expect(c.dialCode.length + c.maxDigits, lessThanOrEqualTo(15), reason: c.name);
      expect(c.minDigits, lessThanOrEqualTo(c.maxDigits), reason: c.name);
    }
  });

  test('parse splits a stored number on the longest calling code', () {
    expect(CountryDialCode.parse('+919876543210')?.country.iso, 'IN');
    expect(CountryDialCode.parse('+919876543210')?.digits, '9876543210');
    expect(CountryDialCode.parse('+9779812345678')?.country.iso, 'NP');
    expect(CountryDialCode.parse('+14155550123', preferred: CountryDialCode.byIso('CA'))?.country.iso, 'CA');
    expect(CountryDialCode.parse('9876543210'), isNull);
  });
}
