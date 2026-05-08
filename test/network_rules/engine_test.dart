import 'package:fl_clash/network_rules/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('evaluate returns fallback action when no rules match', () {
    // intentionally fails: engine.dart does not exist yet
    expect(
      evaluate(
        rules: [],
        snapshot: const NetworkSnapshot.cellular(),
        fallback: Action.keep,
      ),
      Action.keep,
    );
  });
}
