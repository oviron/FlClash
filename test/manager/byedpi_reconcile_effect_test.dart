import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/manager/effects/byedpi_reconcile_effect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('does not reconcile initial settings emission', () {
    final request = byeDpiSettingsReconcileRequest(
      null,
      const ByeDpiSettings(enabled: true),
    );

    expect(request.isEmpty, isTrue);
  });

  test('enabled toggle requires core and engine reconcile', () {
    final request = byeDpiSettingsReconcileRequest(
      const ByeDpiSettings(enabled: false),
      const ByeDpiSettings(enabled: true),
    );

    expect(request.core, isTrue);
    expect(request.engine, isTrue);
  });

  test('fallback group change only requires core reconcile', () {
    final request = byeDpiSettingsReconcileRequest(
      const ByeDpiSettings(fallbackGroup: 'A'),
      const ByeDpiSettings(fallbackGroup: 'B'),
    );

    expect(request.core, isTrue);
    expect(request.engine, isFalse);
  });

  test('preset change only requires engine reconcile', () {
    final request = byeDpiSettingsReconcileRequest(
      const ByeDpiSettings(preset: 'a'),
      const ByeDpiSettings(preset: 'b'),
    );

    expect(request.core, isFalse);
    expect(request.engine, isTrue);
  });
}
