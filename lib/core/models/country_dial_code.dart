import 'dart:ui' show PlatformDispatcher;

/// A country's international calling code, for the phone field's picker.
///
/// [iso] is ISO 3166-1 alpha-2, [dialCode] the ITU calling code without `+`.
/// [minDigits]/[maxDigits] bound the national number (E.164 caps the whole
/// number at 15 digits; the API accepts 8–15).
class CountryDialCode {
  const CountryDialCode(this.iso, this.name, this.dialCode, {int? minDigits, int? maxDigits})
      : _min = minDigits,
        _max = maxDigits;

  final String iso;
  final String name;
  final String dialCode;
  final int? _min;
  final int? _max;

  int get minDigits => _min ?? (8 - dialCode.length).clamp(4, 8);
  int get maxDigits => _max ?? 15 - dialCode.length;

  /// `+91`
  String get prefix => '+$dialCode';

  /// The flag emoji, built from the ISO code's regional-indicator letters.
  String get flag => String.fromCharCodes(iso.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 0x41));

  /// True when [digits] (national number, digits only) is a plausible length.
  bool accepts(String digits) => digits.length >= minDigits && digits.length <= maxDigits;

  /// E.164 for a national number: `+91` + `9876543210`.
  String e164(String digits) => '$prefix$digits';

  static const CountryDialCode india = CountryDialCode('IN', 'India', '91', minDigits: 10, maxDigits: 10);

  /// The device's region (e.g. `en_US` → United States), else India.
  static CountryDialCode get deviceDefault {
    final region = PlatformDispatcher.instance.locale.countryCode;
    return byIso(region) ?? india;
  }

  static CountryDialCode? byIso(String? iso) {
    if (iso == null) return null;
    final code = iso.toUpperCase();
    for (final c in all) {
      if (c.iso == code) return c;
    }
    return null;
  }

  /// Splits a stored E.164 number back into its country and national digits,
  /// preferring the longest matching calling code (and [preferred] on a tie,
  /// e.g. +1 shared by the US and Canada).
  static ({CountryDialCode country, String digits})? parse(String? e164, {CountryDialCode? preferred}) {
    if (e164 == null || !e164.startsWith('+')) return null;
    final number = e164.substring(1);
    CountryDialCode? best;
    for (final c in all) {
      if (!number.startsWith(c.dialCode)) continue;
      final better = best == null ||
          c.dialCode.length > best.dialCode.length ||
          (c.dialCode == best.dialCode && c.iso == preferred?.iso);
      if (better) best = c;
    }
    if (best == null) return null;
    return (country: best, digits: number.substring(best.dialCode.length));
  }

  /// Every country, alphabetical, with India also pinned first in pickers.
  static const List<CountryDialCode> all = [
    CountryDialCode('AF', 'Afghanistan', '93'),
    CountryDialCode('AL', 'Albania', '355'),
    CountryDialCode('DZ', 'Algeria', '213'),
    CountryDialCode('AD', 'Andorra', '376'),
    CountryDialCode('AO', 'Angola', '244'),
    CountryDialCode('AG', 'Antigua and Barbuda', '1'),
    CountryDialCode('AR', 'Argentina', '54'),
    CountryDialCode('AM', 'Armenia', '374'),
    CountryDialCode('AU', 'Australia', '61', minDigits: 9, maxDigits: 9),
    CountryDialCode('AT', 'Austria', '43'),
    CountryDialCode('AZ', 'Azerbaijan', '994'),
    CountryDialCode('BS', 'Bahamas', '1'),
    CountryDialCode('BH', 'Bahrain', '973'),
    CountryDialCode('BD', 'Bangladesh', '880', minDigits: 10, maxDigits: 10),
    CountryDialCode('BB', 'Barbados', '1'),
    CountryDialCode('BY', 'Belarus', '375'),
    CountryDialCode('BE', 'Belgium', '32'),
    CountryDialCode('BZ', 'Belize', '501'),
    CountryDialCode('BJ', 'Benin', '229'),
    CountryDialCode('BT', 'Bhutan', '975'),
    CountryDialCode('BO', 'Bolivia', '591'),
    CountryDialCode('BA', 'Bosnia and Herzegovina', '387'),
    CountryDialCode('BW', 'Botswana', '267'),
    CountryDialCode('BR', 'Brazil', '55'),
    CountryDialCode('BN', 'Brunei', '673'),
    CountryDialCode('BG', 'Bulgaria', '359'),
    CountryDialCode('BF', 'Burkina Faso', '226'),
    CountryDialCode('BI', 'Burundi', '257'),
    CountryDialCode('KH', 'Cambodia', '855'),
    CountryDialCode('CM', 'Cameroon', '237'),
    CountryDialCode('CA', 'Canada', '1', minDigits: 10, maxDigits: 10),
    CountryDialCode('CV', 'Cape Verde', '238'),
    CountryDialCode('CF', 'Central African Republic', '236'),
    CountryDialCode('TD', 'Chad', '235'),
    CountryDialCode('CL', 'Chile', '56'),
    CountryDialCode('CN', 'China', '86'),
    CountryDialCode('CO', 'Colombia', '57'),
    CountryDialCode('KM', 'Comoros', '269'),
    CountryDialCode('CG', 'Congo', '242'),
    CountryDialCode('CD', 'Congo (DRC)', '243'),
    CountryDialCode('CR', 'Costa Rica', '506'),
    CountryDialCode('CI', "Côte d'Ivoire", '225'),
    CountryDialCode('HR', 'Croatia', '385'),
    CountryDialCode('CU', 'Cuba', '53'),
    CountryDialCode('CY', 'Cyprus', '357'),
    CountryDialCode('CZ', 'Czechia', '420'),
    CountryDialCode('DK', 'Denmark', '45'),
    CountryDialCode('DJ', 'Djibouti', '253'),
    CountryDialCode('DM', 'Dominica', '1'),
    CountryDialCode('DO', 'Dominican Republic', '1'),
    CountryDialCode('EC', 'Ecuador', '593'),
    CountryDialCode('EG', 'Egypt', '20'),
    CountryDialCode('SV', 'El Salvador', '503'),
    CountryDialCode('GQ', 'Equatorial Guinea', '240'),
    CountryDialCode('ER', 'Eritrea', '291'),
    CountryDialCode('EE', 'Estonia', '372'),
    CountryDialCode('SZ', 'Eswatini', '268'),
    CountryDialCode('ET', 'Ethiopia', '251'),
    CountryDialCode('FJ', 'Fiji', '679'),
    CountryDialCode('FI', 'Finland', '358'),
    CountryDialCode('FR', 'France', '33', minDigits: 9, maxDigits: 9),
    CountryDialCode('GA', 'Gabon', '241'),
    CountryDialCode('GM', 'Gambia', '220'),
    CountryDialCode('GE', 'Georgia', '995'),
    CountryDialCode('DE', 'Germany', '49'),
    CountryDialCode('GH', 'Ghana', '233'),
    CountryDialCode('GR', 'Greece', '30'),
    CountryDialCode('GD', 'Grenada', '1'),
    CountryDialCode('GT', 'Guatemala', '502'),
    CountryDialCode('GN', 'Guinea', '224'),
    CountryDialCode('GW', 'Guinea-Bissau', '245'),
    CountryDialCode('GY', 'Guyana', '592'),
    CountryDialCode('HT', 'Haiti', '509'),
    CountryDialCode('HN', 'Honduras', '504'),
    CountryDialCode('HK', 'Hong Kong', '852'),
    CountryDialCode('HU', 'Hungary', '36'),
    CountryDialCode('IS', 'Iceland', '354'),
    CountryDialCode('IN', 'India', '91', minDigits: 10, maxDigits: 10),
    CountryDialCode('ID', 'Indonesia', '62'),
    CountryDialCode('IR', 'Iran', '98'),
    CountryDialCode('IQ', 'Iraq', '964'),
    CountryDialCode('IE', 'Ireland', '353'),
    CountryDialCode('IL', 'Israel', '972'),
    CountryDialCode('IT', 'Italy', '39'),
    CountryDialCode('JM', 'Jamaica', '1'),
    CountryDialCode('JP', 'Japan', '81'),
    CountryDialCode('JO', 'Jordan', '962'),
    CountryDialCode('KZ', 'Kazakhstan', '7'),
    CountryDialCode('KE', 'Kenya', '254'),
    CountryDialCode('KI', 'Kiribati', '686'),
    CountryDialCode('KW', 'Kuwait', '965'),
    CountryDialCode('KG', 'Kyrgyzstan', '996'),
    CountryDialCode('LA', 'Laos', '856'),
    CountryDialCode('LV', 'Latvia', '371'),
    CountryDialCode('LB', 'Lebanon', '961'),
    CountryDialCode('LS', 'Lesotho', '266'),
    CountryDialCode('LR', 'Liberia', '231'),
    CountryDialCode('LY', 'Libya', '218'),
    CountryDialCode('LI', 'Liechtenstein', '423'),
    CountryDialCode('LT', 'Lithuania', '370'),
    CountryDialCode('LU', 'Luxembourg', '352'),
    CountryDialCode('MO', 'Macao', '853'),
    CountryDialCode('MG', 'Madagascar', '261'),
    CountryDialCode('MW', 'Malawi', '265'),
    CountryDialCode('MY', 'Malaysia', '60'),
    CountryDialCode('MV', 'Maldives', '960'),
    CountryDialCode('ML', 'Mali', '223'),
    CountryDialCode('MT', 'Malta', '356'),
    CountryDialCode('MH', 'Marshall Islands', '692'),
    CountryDialCode('MR', 'Mauritania', '222'),
    CountryDialCode('MU', 'Mauritius', '230'),
    CountryDialCode('MX', 'Mexico', '52'),
    CountryDialCode('FM', 'Micronesia', '691'),
    CountryDialCode('MD', 'Moldova', '373'),
    CountryDialCode('MC', 'Monaco', '377'),
    CountryDialCode('MN', 'Mongolia', '976'),
    CountryDialCode('ME', 'Montenegro', '382'),
    CountryDialCode('MA', 'Morocco', '212'),
    CountryDialCode('MZ', 'Mozambique', '258'),
    CountryDialCode('MM', 'Myanmar', '95'),
    CountryDialCode('NA', 'Namibia', '264'),
    CountryDialCode('NR', 'Nauru', '674'),
    CountryDialCode('NP', 'Nepal', '977', minDigits: 10, maxDigits: 10),
    CountryDialCode('NL', 'Netherlands', '31', minDigits: 9, maxDigits: 9),
    CountryDialCode('NZ', 'New Zealand', '64'),
    CountryDialCode('NI', 'Nicaragua', '505'),
    CountryDialCode('NE', 'Niger', '227'),
    CountryDialCode('NG', 'Nigeria', '234'),
    CountryDialCode('KP', 'North Korea', '850'),
    CountryDialCode('MK', 'North Macedonia', '389'),
    CountryDialCode('NO', 'Norway', '47'),
    CountryDialCode('OM', 'Oman', '968'),
    CountryDialCode('PK', 'Pakistan', '92', minDigits: 10, maxDigits: 10),
    CountryDialCode('PW', 'Palau', '680'),
    CountryDialCode('PS', 'Palestine', '970'),
    CountryDialCode('PA', 'Panama', '507'),
    CountryDialCode('PG', 'Papua New Guinea', '675'),
    CountryDialCode('PY', 'Paraguay', '595'),
    CountryDialCode('PE', 'Peru', '51'),
    CountryDialCode('PH', 'Philippines', '63'),
    CountryDialCode('PL', 'Poland', '48'),
    CountryDialCode('PT', 'Portugal', '351'),
    CountryDialCode('QA', 'Qatar', '974'),
    CountryDialCode('RO', 'Romania', '40'),
    CountryDialCode('RU', 'Russia', '7'),
    CountryDialCode('RW', 'Rwanda', '250'),
    CountryDialCode('KN', 'Saint Kitts and Nevis', '1'),
    CountryDialCode('LC', 'Saint Lucia', '1'),
    CountryDialCode('VC', 'Saint Vincent and the Grenadines', '1'),
    CountryDialCode('WS', 'Samoa', '685'),
    CountryDialCode('SM', 'San Marino', '378'),
    CountryDialCode('ST', 'São Tomé and Príncipe', '239'),
    CountryDialCode('SA', 'Saudi Arabia', '966', minDigits: 9, maxDigits: 9),
    CountryDialCode('SN', 'Senegal', '221'),
    CountryDialCode('RS', 'Serbia', '381'),
    CountryDialCode('SC', 'Seychelles', '248'),
    CountryDialCode('SL', 'Sierra Leone', '232'),
    CountryDialCode('SG', 'Singapore', '65', minDigits: 8, maxDigits: 8),
    CountryDialCode('SK', 'Slovakia', '421'),
    CountryDialCode('SI', 'Slovenia', '386'),
    CountryDialCode('SB', 'Solomon Islands', '677'),
    CountryDialCode('SO', 'Somalia', '252'),
    CountryDialCode('ZA', 'South Africa', '27', minDigits: 9, maxDigits: 9),
    CountryDialCode('KR', 'South Korea', '82'),
    CountryDialCode('SS', 'South Sudan', '211'),
    CountryDialCode('ES', 'Spain', '34', minDigits: 9, maxDigits: 9),
    CountryDialCode('LK', 'Sri Lanka', '94', minDigits: 9, maxDigits: 9),
    CountryDialCode('SD', 'Sudan', '249'),
    CountryDialCode('SR', 'Suriname', '597'),
    CountryDialCode('SE', 'Sweden', '46'),
    CountryDialCode('CH', 'Switzerland', '41'),
    CountryDialCode('SY', 'Syria', '963'),
    CountryDialCode('TW', 'Taiwan', '886'),
    CountryDialCode('TJ', 'Tajikistan', '992'),
    CountryDialCode('TZ', 'Tanzania', '255'),
    CountryDialCode('TH', 'Thailand', '66'),
    CountryDialCode('TL', 'Timor-Leste', '670'),
    CountryDialCode('TG', 'Togo', '228'),
    CountryDialCode('TO', 'Tonga', '676'),
    CountryDialCode('TT', 'Trinidad and Tobago', '1'),
    CountryDialCode('TN', 'Tunisia', '216'),
    CountryDialCode('TR', 'Türkiye', '90'),
    CountryDialCode('TM', 'Turkmenistan', '993'),
    CountryDialCode('TV', 'Tuvalu', '688'),
    CountryDialCode('UG', 'Uganda', '256'),
    CountryDialCode('UA', 'Ukraine', '380'),
    CountryDialCode('AE', 'United Arab Emirates', '971', minDigits: 9, maxDigits: 9),
    CountryDialCode('GB', 'United Kingdom', '44', minDigits: 10, maxDigits: 10),
    CountryDialCode('US', 'United States', '1', minDigits: 10, maxDigits: 10),
    CountryDialCode('UY', 'Uruguay', '598'),
    CountryDialCode('UZ', 'Uzbekistan', '998'),
    CountryDialCode('VU', 'Vanuatu', '678'),
    CountryDialCode('VA', 'Vatican City', '39'),
    CountryDialCode('VE', 'Venezuela', '58'),
    CountryDialCode('VN', 'Vietnam', '84'),
    CountryDialCode('YE', 'Yemen', '967'),
    CountryDialCode('ZM', 'Zambia', '260'),
    CountryDialCode('ZW', 'Zimbabwe', '263'),
  ];
}
