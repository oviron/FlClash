library;

import 'routing_model.dart';

/// A country for the "by IP" (GEOIP) List source. This is standard ISO-3166
/// reference data for the country picker (a system enumeration, like the
/// installed-app list) — not curated content. The matcher value is the code.
class CountryEntry {
  final String code;
  final String flag;
  final Map<String, String> labels;

  const CountryEntry({
    required this.code,
    required this.flag,
    required this.labels,
  });
}

const List<CountryEntry> routingCountries = [
  CountryEntry(
    code: 'RU',
    flag: '🇷🇺',
    labels: {'en': 'Russia', 'ru': 'Россия', 'ja': 'ロシア', 'zh_CN': '俄罗斯'},
  ),
  CountryEntry(
    code: 'US',
    flag: '🇺🇸',
    labels: {'en': 'United States', 'ru': 'США', 'ja': 'アメリカ', 'zh_CN': '美国'},
  ),
  CountryEntry(
    code: 'DE',
    flag: '🇩🇪',
    labels: {'en': 'Germany', 'ru': 'Германия', 'ja': 'ドイツ', 'zh_CN': '德国'},
  ),
  CountryEntry(
    code: 'NL',
    flag: '🇳🇱',
    labels: {
      'en': 'Netherlands',
      'ru': 'Нидерланды',
      'ja': 'オランダ',
      'zh_CN': '荷兰',
    },
  ),
  CountryEntry(
    code: 'GB',
    flag: '🇬🇧',
    labels: {
      'en': 'United Kingdom',
      'ru': 'Великобритания',
      'ja': 'イギリス',
      'zh_CN': '英国',
    },
  ),
  CountryEntry(
    code: 'FR',
    flag: '🇫🇷',
    labels: {'en': 'France', 'ru': 'Франция', 'ja': 'フランス', 'zh_CN': '法国'},
  ),
  CountryEntry(
    code: 'FI',
    flag: '🇫🇮',
    labels: {'en': 'Finland', 'ru': 'Финляндия', 'ja': 'フィンランド', 'zh_CN': '芬兰'},
  ),
  CountryEntry(
    code: 'SE',
    flag: '🇸🇪',
    labels: {'en': 'Sweden', 'ru': 'Швеция', 'ja': 'スウェーデン', 'zh_CN': '瑞典'},
  ),
  CountryEntry(
    code: 'TR',
    flag: '🇹🇷',
    labels: {'en': 'Türkiye', 'ru': 'Турция', 'ja': 'トルコ', 'zh_CN': '土耳其'},
  ),
  CountryEntry(
    code: 'JP',
    flag: '🇯🇵',
    labels: {'en': 'Japan', 'ru': 'Япония', 'ja': '日本', 'zh_CN': '日本'},
  ),
  CountryEntry(
    code: 'SG',
    flag: '🇸🇬',
    labels: {
      'en': 'Singapore',
      'ru': 'Сингапур',
      'ja': 'シンガポール',
      'zh_CN': '新加坡',
    },
  ),
];

CountryEntry? countryEntry(String code) {
  for (final c in routingCountries) {
    if (c.code == code) return c;
  }
  return null;
}

/// The display label for [labels] in [localeCode], falling back to `en`.
String localeLabel(Map<String, String> labels, String localeCode) =>
    labels[localeCode] ?? labels['en'] ?? '';

/// A country-backed List (a `GEOIP,<code>` matcher, no provider). The name is
/// the country's own name, not curated content.
RoutingList countryList(String code, {String locale = 'en'}) {
  final c = countryEntry(code)!;
  return RoutingList(
    id: code,
    name: localeLabel(c.labels, locale),
    kind: ListKind.country,
    countryCode: code,
  );
}
