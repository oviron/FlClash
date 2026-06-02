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

    test(
      'null expectedAbi (e.g. byedpi absent in classic) is incompatible',
      () {
        expect(
          _rel(
            abi: 1,
          ).compatibleWith(expectedAbi: null, deviceAbi: 'arm64-v8a'),
          isFalse,
        );
      },
    );
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
}
