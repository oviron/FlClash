import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/profiles/app_routing_model.dart';
import 'package:flutter_test/flutter_test.dart';

Package _pkg(String name, String label, {bool system = false}) => Package(
  packageName: name,
  label: label,
  system: system,
  internet: true,
  lastUpdateTime: 0,
);

void main() {
  final apps = [
    _pkg('com.chrome', 'Chrome'),
    _pkg('com.bank', 'Bank App'),
    _pkg('com.android.sys', 'System Thing', system: true),
  ];

  test('hides system apps by default, sorts by label', () {
    final r = filterRoutingApps(apps, query: '', showSystem: false);
    expect(r.map((p) => p.packageName), ['com.bank', 'com.chrome']);
    expect(r.any((p) => p.system), false);
  });

  test('shows system apps when enabled', () {
    expect(filterRoutingApps(apps, query: '', showSystem: true).length, 3);
  });

  test('query filters by label and package, case-insensitive', () {
    expect(
      filterRoutingApps(apps, query: 'chr', showSystem: false).single.label,
      'Chrome',
    );
    expect(
      filterRoutingApps(apps, query: 'BANK', showSystem: false).single.label,
      'Bank App',
    );
    expect(
      filterRoutingApps(
        apps,
        query: 'com.bank',
        showSystem: false,
      ).single.label,
      'Bank App',
    );
  });

  test('no match yields empty (drives the empty-state)', () {
    expect(filterRoutingApps(apps, query: 'zzz', showSystem: true), isEmpty);
  });
}
