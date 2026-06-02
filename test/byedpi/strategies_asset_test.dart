import 'dart:io';

import 'package:fl_clash/byedpi/strategy_args.dart';
import 'package:flutter_test/flutter_test.dart';

// Guards the shipped/released strategy set against a malformed edit: it must
// parse with the app's own validator, and fake-packet (-l:) args must carry
// raw \xNN escapes with no ByeByeDPI-style quotes (byedpi's ftob copies quotes
// literally into the payload).
void main() {
  test('byedpi-strategies.json parses and is well-formed', () {
    final raw = File('assets/data/byedpi-strategies.json').readAsStringSync();
    final list = parseStrategyList(raw);

    expect(list.length, greaterThanOrEqualTo(80));
    expect(list.first.id, 'universal');
    expect(list.map((e) => e.id).toSet().length, list.length); // unique ids

    for (final s in list) {
      expect(s.args.contains('"'), isFalse, reason: '${s.id} has a literal quote');
      expect(s.args.contains('{sni}'), isFalse, reason: '${s.id} has an unresolved {sni}');
    }
  });
}
