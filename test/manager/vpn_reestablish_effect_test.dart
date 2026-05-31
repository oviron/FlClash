import 'package:fl_clash/manager/effects/vpn_reestablish_effect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldScheduleVpnReestablish', () {
    test('schedules when started and state differs', () {
      expect(
        shouldScheduleVpnReestablish(
          isStarted: true,
          currentVpnState: 'next',
          lastVpnState: 'prev',
        ),
        isTrue,
      );
    });

    test('does not schedule while stopped or already reestablishing', () {
      expect(
        shouldScheduleVpnReestablish(
          isStarted: false,
          currentVpnState: 'next',
          lastVpnState: 'prev',
        ),
        isFalse,
      );
      expect(
        shouldScheduleVpnReestablish(
          isStarted: true,
          currentVpnState: 'next',
          lastVpnState: 'prev',
          isReestablishing: true,
        ),
        isFalse,
      );
    });
  });

  group('shouldReestablishVpnForByeDpiToggle', () {
    test('schedules running VPN when ByeDPI enabled flag changes', () {
      expect(
        shouldReestablishVpnForByeDpiToggle(
          isStarted: true,
          previousEnabled: false,
          nextEnabled: true,
        ),
        isTrue,
      );
    });

    test('ignores initial emission and stopped VPN', () {
      expect(
        shouldReestablishVpnForByeDpiToggle(
          isStarted: true,
          previousEnabled: null,
          nextEnabled: true,
        ),
        isFalse,
      );
      expect(
        shouldReestablishVpnForByeDpiToggle(
          isStarted: false,
          previousEnabled: false,
          nextEnabled: true,
        ),
        isFalse,
      );
    });
  });
}
