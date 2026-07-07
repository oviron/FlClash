import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tun.mtu', () {
    test('defaults to the mobile-tuned 1400', () {
      expect(const Tun().mtu, 1400);
    });

    test('fromJson maps the "mtu" key (so an imported config controls it)', () {
      expect(Tun.fromJson(const {'mtu': 1280}).mtu, 1280);
    });

    test('toJson emits mtu (UI value reaches the exported YAML)', () {
      expect(const Tun(mtu: 9000).toJson()['mtu'], 9000);
    });

    test('getRealTun preserves mtu', () {
      expect(const Tun(mtu: 1280).getRealTun(RouteMode.config).mtu, 1280);
    });
  });

  group('VpnState establish fingerprint', () {
    const base = VpnState(stack: TunStack.gvisor, vpnProps: VpnProps());

    test('mtu defaults to 1400', () {
      expect(base.mtu, 1400);
    });

    test('a differing mtu breaks equality, forcing a re-establish', () {
      expect(base == base.copyWith(mtu: 9000), isFalse);
    });

    test(
      'an unchanged mtu keeps equality, avoiding a needless re-establish',
      () {
        expect(base == base.copyWith(mtu: 1400), isTrue);
      },
    );
  });
}
