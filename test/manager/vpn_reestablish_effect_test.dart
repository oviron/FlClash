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

    test('does not schedule while stopped', () {
      expect(
        shouldScheduleVpnReestablish(
          isStarted: false,
          currentVpnState: 'next',
          lastVpnState: 'prev',
        ),
        isFalse,
      );
    });

    test('does not schedule when state is unchanged', () {
      expect(
        shouldScheduleVpnReestablish(
          isStarted: true,
          currentVpnState: 'same',
          lastVpnState: 'same',
        ),
        isFalse,
      );
    });
  });

  group('shouldRunVpnReestablish', () {
    test('runs when forced even when vpn state is unchanged', () {
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

    test('does not run when stopped', () {
      expect(
        shouldRunVpnReestablish(
          isStarted: false,
          forceReestablish: true,
          currentVpnState: 'same',
          lastVpnState: 'same',
        ),
        isFalse,
      );
    });
  });
}
