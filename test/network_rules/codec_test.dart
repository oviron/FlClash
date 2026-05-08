import 'package:fl_clash/network_rules/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkConditionListCodec.decode', () {
    test('roundtrip encode/decode preserves the three known kinds', () {
      const original = <NetworkCondition>[
        AnyWifi(),
        AnyCellular(),
        WifiNamed('Home'),
      ];
      final encoded = NetworkConditionListCodec.encode(original);
      final decoded = NetworkConditionListCodec.decode(encoded);
      expect(decoded, original);
    });

    test('skips unknown kinds instead of throwing', () {
      // A future version could write a kind we do not know about. We must
      // keep the rest of the conditions visible — losing one record cannot
      // be allowed to wipe the entire user rules list.
      const json =
          '[{"kind":"any_wifi"},'
          '{"kind":"future_geofence","lat":1,"lon":2},'
          '{"kind":"wifi_named","ssid":"Home"}]';
      final decoded = NetworkConditionListCodec.decode(json);
      expect(decoded, [const AnyWifi(), const WifiNamed('Home')]);
    });

    test('empty string decodes to empty list', () {
      expect(NetworkConditionListCodec.decode(''), isEmpty);
    });

    test('throws when the outer JSON is not an array', () {
      expect(
        () => NetworkConditionListCodec.decode('{"kind":"any_wifi"}'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
