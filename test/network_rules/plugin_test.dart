import 'package:fl_clash/network_rules/engine.dart';
import 'package:fl_clash/network_rules/plugin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkRulesPlugin.parseStatus', () {
    test('wifi + start carries ssid, reason, overridden', () {
      final s = NetworkRulesPlugin.parseStatus(const {
        'type': 'WIFI',
        'ssid': 'Home',
        'decision': 'START',
        'reason': 'matched',
        'overridden': true,
      });
      expect(s.snapshot.type.name, 'wifi');
      expect(s.snapshot.ssid, 'Home');
      expect(s.decision, NetworkDecision.start);
      expect(s.reason, 'matched');
      expect(s.overridden, true);
    });

    test('cellular + stop', () {
      final s = NetworkRulesPlugin.parseStatus(const {
        'type': 'CELLULAR',
        'decision': 'STOP',
      });
      expect(s.snapshot.type.name, 'cellular');
      expect(s.decision, NetworkDecision.stop);
    });

    test('ethernet + unknown decision defaults to leaveAsIs', () {
      final s = NetworkRulesPlugin.parseStatus(const {
        'type': 'ETHERNET',
        'decision': 'WHAT',
      });
      expect(s.snapshot.type.name, 'ethernet');
      expect(s.decision, NetworkDecision.leaveAsIs);
    });

    test('unknown type maps to none, missing fields default', () {
      final s = NetworkRulesPlugin.parseStatus(const {});
      expect(s.snapshot.type.name, 'none');
      expect(s.snapshot.ssid, isNull);
      expect(s.decision, NetworkDecision.leaveAsIs);
      expect(s.reason, '');
      expect(s.overridden, false);
    });
  });
}
