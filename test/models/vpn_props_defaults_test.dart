import 'package:fl_clash/models/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'fresh VpnProps defaults: DNS hijack on, bypass off, system proxy off',
    () {
      const props = VpnProps();
      expect(props.dnsHijacking, isTrue);
      expect(props.allowBypass, isFalse);
      expect(props.systemProxy, isFalse);
    },
  );
}
