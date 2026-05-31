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

  group('shouldRunVpnReestablish', () {
    test('runs for forced ByeDPI toggle even when vpn state is unchanged', () {
      expect(
        shouldRunVpnReestablish(
          isStarted: true,
          forceReestablish: true,
          currentVpnState: 'same',
          lastVpnState: 'same',
        ),
        isTrue,
      );
    });

    test('does not run when stopped or already reestablishing', () {
      expect(
        shouldRunVpnReestablish(
          isStarted: false,
          forceReestablish: true,
          currentVpnState: 'same',
          lastVpnState: 'same',
        ),
        isFalse,
      );
      expect(
        shouldRunVpnReestablish(
          isStarted: true,
          forceReestablish: true,
          currentVpnState: 'same',
          lastVpnState: 'same',
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
