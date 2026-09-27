import 'package:fl_clash/common/compute.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

TrackerInfo _t(
  String id, {
  int upload = 0,
  int download = 0,
  int? uploadSpeed,
  int? downloadSpeed,
  String process = '',
}) => TrackerInfo(
  id: id,
  upload: upload,
  download: download,
  start: DateTime(2020),
  metadata: Metadata(process: process),
  chains: const [],
  rule: '',
  rulePayload: '',
  uploadSpeed: uploadSpeed,
  downloadSpeed: downloadSpeed,
);

void main() {
  group('TrackerInfosState.list sorting', () {
    // traffic: a=15, b=100, c=50 ; speed: a=2, b=0, c=15
    final a = _t(
      'a',
      upload: 10,
      download: 5,
      uploadSpeed: 1,
      downloadSpeed: 1,
    );
    final b = _t('b', upload: 100, uploadSpeed: 0, downloadSpeed: 0);
    final c = _t('c', download: 50, uploadSpeed: 10, downloadSpeed: 5);
    final infos = [a, b, c];

    test('none keeps original order', () {
      final state = TrackerInfosState(
        trackerInfos: infos,
        sortType: ConnectionsSortType.none,
      );
      expect(state.list.map((e) => e.id).toList(), ['a', 'b', 'c']);
    });

    test('traffic sorts by total bytes descending', () {
      final state = TrackerInfosState(
        trackerInfos: infos,
        sortType: ConnectionsSortType.traffic,
      );
      expect(state.list.map((e) => e.id).toList(), ['b', 'c', 'a']);
    });

    test('speed sorts by total speed descending, null treated as zero', () {
      final state = TrackerInfosState(
        trackerInfos: infos,
        sortType: ConnectionsSortType.speed,
      );
      expect(state.list.map((e) => e.id).toList(), ['c', 'a', 'b']);
    });
  });

  group('computeConnectionSpeeds', () {
    test('derives up/down speed from byte delta over the interval', () {
      final prev = {'a': (upload: 100, download: 200)};
      final out = computeConnectionSpeeds(
        [_t('a', upload: 300, download: 500)],
        prev,
        2.0,
      );
      expect(out.single.uploadSpeed, 100);
      expect(out.single.downloadSpeed, 150);
    });

    test('missing previous snapshot yields zero speed', () {
      final out = computeConnectionSpeeds(
        [_t('x', upload: 5, download: 5)],
        const {},
        1.0,
      );
      expect(out.single.uploadSpeed, 0);
      expect(out.single.downloadSpeed, 0);
    });

    test('counter reset (negative delta) clamps to zero', () {
      final prev = {'a': (upload: 1000, download: 1000)};
      final out = computeConnectionSpeeds(
        [_t('a', upload: 10, download: 10)],
        prev,
        1.0,
      );
      expect(out.single.uploadSpeed, 0);
      expect(out.single.downloadSpeed, 0);
    });
  });

  group('connectionProcesses', () {
    test('distinct, non-empty, sorted case-insensitively', () {
      final infos = [
        _t('a', process: 'chrome'),
        _t('b', process: 'Telegram'),
        _t('c', process: 'chrome'),
        _t('d', process: ''),
      ];
      expect(connectionProcesses(infos), ['chrome', 'Telegram']);
    });
  });

  group('resolveProcessFilter', () {
    test('keeps an empty filter (all) as-is', () {
      expect(resolveProcessFilter('', ['chrome']), '');
    });

    test('keeps a filter that is still present', () {
      expect(resolveProcessFilter('chrome', ['chrome', 'telegram']), 'chrome');
    });

    test('falls back to all once the app vanishes from the list', () {
      expect(resolveProcessFilter('chrome', ['telegram']), '');
      expect(resolveProcessFilter('chrome', []), '');
    });
  });

  group('TrackerInfosState.list process filter', () {
    final chrome1 = _t('a', process: 'chrome');
    final chrome2 = _t('b', process: 'chrome');
    final telegram = _t('c', process: 'telegram');
    final infos = [chrome1, chrome2, telegram];

    test('empty filter keeps everything', () {
      final state = TrackerInfosState(trackerInfos: infos);
      expect(state.list.map((e) => e.id).toSet(), {'a', 'b', 'c'});
    });

    test('a set filter keeps only that process', () {
      final state = TrackerInfosState(
        trackerInfos: infos,
        processFilter: 'chrome',
      );
      expect(state.list.map((e) => e.id).toSet(), {'a', 'b'});
    });

    test('combines with the search query', () {
      final state = TrackerInfosState(
        trackerInfos: infos,
        processFilter: 'chrome',
        query: 'nonexistent-host',
      );
      expect(state.list, isEmpty);
    });

    test('a stale filter (its app is gone) falls back to all instead of an '
        'empty screen', () {
      final state = TrackerInfosState(
        trackerInfos: [telegram],
        processFilter: 'chrome',
      );
      expect(state.list.map((e) => e.id).toList(), ['c']);
      expect(state.resolvedProcessFilter, '');
    });
  });
}
