import 'package:fl_clash/library/model.dart';
import 'package:flutter_test/flutter_test.dart';

LibraryRelease _rel({
  required int abi,
  List<String> abis = const ['arm64-v8a'],
}) => LibraryRelease(
  label: kLibMihomo,
  version: '0.1.4',
  coreName: 'mihomo',
  coreVersion: 'v1.19.26',
  bridgeAbi: abi,
  abis: abis,
  aarUrl: 'https://example/a.aar',
  ascUrl: 'https://example/a.aar.asc',
  sha256: 'deadbeef',
);

void main() {
  group('LibraryRelease.compatibleWith', () {
    test('matching bridgeABI + device abi present is compatible', () {
      expect(
        _rel(abi: 1).compatibleWith(expectedAbi: 1, deviceAbi: 'arm64-v8a'),
        isTrue,
      );
    });

    test('mismatched bridgeABI is incompatible (needs app update)', () {
      expect(
        _rel(abi: 2).compatibleWith(expectedAbi: 1, deviceAbi: 'arm64-v8a'),
        isFalse,
      );
    });

    test('device abi absent from release abis is incompatible', () {
      expect(
        _rel(
          abi: 1,
          abis: const ['x86_64'],
        ).compatibleWith(expectedAbi: 1, deviceAbi: 'arm64-v8a'),
        isFalse,
      );
    });

    test('null expectedAbi is incompatible', () {
      expect(
        _rel(abi: 1).compatibleWith(expectedAbi: null, deviceAbi: 'arm64-v8a'),
        isFalse,
      );
    });
  });

  group('InstalledLibrary.fromMap', () {
    test('parses native map', () {
      final lib = InstalledLibrary.fromMap({
        'label': 'mihomo',
        'version': '0.1.4',
        'dir': '/data/data/x/files/libs/mihomo-v0.1.4',
        'sizeBytes': 36000000,
      });
      expect(lib.label, 'mihomo');
      expect(lib.version, '0.1.4');
      expect(lib.sizeBytes, 36000000);
    });
  });

  group('RunningCore', () {
    RunningCore rc(String? selected, List<String> cores) =>
        RunningCore.fromMap({'selected': selected, 'cores': cores});

    test('the selected copy alone is the running core', () {
      final r = rc('/f/libs/mihomo-v0.3.13-oviron.1', ['selected']);
      expect(r.source, RunningCoreSource.selected);
      expect(r.selectionFailed, isFalse);
    });

    test('a selected copy next to the APK copy did not attach', () {
      final r = rc('/f/libs/mihomo-v0.3.12-oviron.1', ['selected', 'bundled']);
      expect(r.source, RunningCoreSource.bundled);
      expect(r.selectionFailed, isTrue);
    });

    test('the bundled default is no failure', () {
      final r = rc(null, ['bundled']);
      expect(r.source, RunningCoreSource.bundled);
      expect(r.selectionFailed, isFalse);
    });

    test('an unmapped or foreign core is unknown', () {
      expect(rc('/f/libs/mihomo-v1', []).source, RunningCoreSource.unknown);
      expect(rc(null, ['/other']).source, RunningCoreSource.unknown);
      expect(rc('/f/libs/mihomo-v1', ['/other']).selectionFailed, isTrue);
    });

    test('version comes from the install dir name', () {
      expect(
        libVersionFromDir('/data/user/0/x/files/libs/mihomo-v0.3.12-oviron.1'),
        'v0.3.12-oviron.1',
      );
    });
  });
}
