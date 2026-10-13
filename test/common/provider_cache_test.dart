import 'dart:io';

import 'package:fl_clash/common/provider_cache.dart';
import 'package:fl_clash/common/string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

void main() {
  const blanc = {'type': 'http', 'url': 'https://sub.test/blanc'};

  String pathOf(
    Map<String, Object> provider, {
    String name = 'blanc',
    Object? userAgent = 'clash.meta',
  }) =>
      providerCachePath('/p', 'proxies', name, provider, userAgent: userAgent);

  group('the path a provider is cached at', () {
    test('is the same for one request in any profile', () {
      expect(pathOf(blanc), pathOf({...blanc, 'interval': 600}, name: 'b'));
    });

    test('differs with the User-Agent or the headers, as the reply may', () {
      expect(pathOf(blanc, userAgent: 'other'), isNot(pathOf(blanc)));
      expect(
        pathOf({
          ...blanc,
          'header': {
            'Authorization': ['x'],
          },
        }),
        isNot(pathOf(blanc)),
      );
    });

    test('differs with the size limit, which cuts the stored body', () {
      expect(pathOf({...blanc, 'size-limit': 100}), isNot(pathOf(blanc)));
      expect(pathOf({...blanc, 'size-limit': 0}), pathOf(blanc));
    });

    test('of a converted subscription differs by conversion and name', () {
      final grouped = {
        ...blanc,
        'xray': {'groups': 'by-remark'},
      };
      expect(pathOf(grouped), isNot(pathOf(blanc)));
      expect(
        pathOf(grouped),
        isNot(pathOf({...blanc, 'xray': <String, Object>{}})),
      );
      expect(pathOf(grouped, name: 'other'), isNot(pathOf(grouped)));
    });
  });

  group('the shared cache', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('providers');
    });

    tearDown(() async {
      await root.delete(recursive: true);
    });

    File file(String path) => File(join(root.path, path));

    Future<void> write(String path, [String content = 'x']) async {
      await file(path).parent.create(recursive: true);
      await file(path).writeAsString(content);
    }

    Future<void> put(String path, String content) async {
      await File(path).parent.create(recursive: true);
      await File(path).writeAsString(content);
    }

    Map<String, dynamic> config(Map<String, String> urls) => {
      'proxy-providers': {
        for (final MapEntry(:key, value: url) in urls.entries)
          key: {
            'type': 'http',
            'url': url,
            'path': providerCachePath(root.path, 'proxies', key, {
              'url': url,
            }, userAgent: 'ua'),
          },
      },
    };

    String shared(String url) => providerCachePath(
      root.path,
      'proxies',
      'any',
      {'url': url},
      userAgent: 'ua',
    );

    test('takes over a profile\'s file from older versions', () async {
      const url = 'https://sub.test/blanc';
      await write('1/proxies/${url.toMd5()}', 'old');
      await write('1/proxies/${url.toMd5()}.remarks.json', '[]');
      await write('1/proxies/stale');
      await claimProviderCache(root.path, 1, config({'b': url}), [1]);
      expect(await File(shared(url)).readAsString(), 'old');
      expect(await File('${shared(url)}.remarks.json').exists(), isTrue);
      expect(await Directory(join(root.path, '1')).exists(), isFalse);
    });

    test('keeps the shared copy over a second profile\'s own', () async {
      const url = 'https://sub.test/blanc';
      await claimProviderCache(root.path, 1, config({'b': url}), [1, 2]);
      await put(shared(url), 'shared');
      await write('2/proxies/${url.toMd5()}', 'old');
      await claimProviderCache(root.path, 2, config({'b': url}), [1, 2]);
      expect(await File(shared(url)).readAsString(), 'shared');
      expect(await Directory(join(root.path, '2')).exists(), isFalse);
    });

    test('keeps a file another profile uses when one is deleted', () async {
      const url = 'https://sub.test/blanc';
      await claimProviderCache(root.path, 1, config({'b': url}), [1, 2]);
      await claimProviderCache(root.path, 2, config({'b': url}), [1, 2]);
      await put(shared(url), 'shared');
      await releaseProviderCache(root.path, 1, [2]);
      expect(await File(shared(url)).exists(), isTrue);
      await releaseProviderCache(root.path, 2, []);
      expect(await File(shared(url)).exists(), isFalse);
    });

    test('drops the file of a url the profile no longer uses', () async {
      await claimProviderCache(root.path, 1, config({'b': 'https://old'}), [1]);
      await put(shared('https://old'), 'x');
      await put('${shared('https://old')}.remarks.json', '[]');
      await claimProviderCache(root.path, 1, config({'b': 'https://new'}), [1]);
      expect(await File(shared('https://old')).exists(), isFalse);
      expect(
        await File('${shared('https://old')}.remarks.json').exists(),
        isFalse,
      );
    });

    test('keeps both profiles\' files when two are applied at once', () async {
      const url = 'https://sub.test/blanc';
      await write('1/proxies/${url.toMd5()}');
      await write('2/proxies/${'https://other'.toMd5()}');
      await Future.wait([
        claimProviderCache(root.path, 1, config({'b': url}), [1, 2]),
        claimProviderCache(root.path, 2, config({'o': 'https://other'}), [
          1,
          2,
        ]),
      ]);
      expect(await File(shared(url)).exists(), isTrue);
      expect(await File(shared('https://other')).exists(), isTrue);
    });

    test('keeps the files it used until the core applied the config', () async {
      await claimProviderCache(root.path, 1, config({'b': 'https://old'}), [1]);
      await put(shared('https://old'), 'x');
      final release = await reserveProviderCache(
        root.path,
        1,
        config({'b': 'https://new'}),
      );
      release();
      await claimProviderCache(root.path, 2, config({}), [1, 2]);
      expect(await File(shared('https://old')).exists(), isTrue);
    });

    test('copies an old file in before the core applied the config', () async {
      const url = 'https://sub.test/blanc';
      await write('1/proxies/${url.toMd5()}', 'old');
      (await reserveProviderCache(root.path, 1, config({'b': url})))();
      expect(await File(shared(url)).readAsString(), 'old');
      expect(await file('1/proxies/${url.toMd5()}').exists(), isTrue);
    });

    test('counts a subscription the app turned into a file', () async {
      await put(shared('https://a'), 'x');
      await claimProviderCache(
        root.path,
        1,
        {
          'proxy-providers': {
            'b': {'type': 'file', 'path': shared('https://a')},
          },
        },
        [1],
      );
      expect(await File(shared('https://a')).exists(), isTrue);
    });

    test('leaves a write in progress alone', () async {
      await put('${shared('https://a')}.1.tmp', 'x');
      await claimProviderCache(root.path, 1, config({}), [1]);
      expect(await File('${shared('https://a')}.1.tmp').exists(), isTrue);
    });

    test('keeps the old folder while a file provider reads from it', () async {
      await write('1/rules/mine.yaml');
      await claimProviderCache(
        root.path,
        1,
        {
          'rule-providers': {
            'm': {'type': 'file', 'path': join(root.path, '1/rules/mine.yaml')},
          },
        },
        [1],
      );
      expect(await file('1/rules/mine.yaml').exists(), isTrue);
    });

    test('keeps the files of an apply still under way', () async {
      final release = await reserveProviderCache(
        root.path,
        1,
        config({'b': 'https://next'}),
      );
      await put(shared('https://next'), 'x');
      await claimProviderCache(root.path, 1, config({'b': 'https://old'}), [1]);
      expect(await File(shared('https://next')).exists(), isTrue);
      release();
      await claimProviderCache(root.path, 1, config({'b': 'https://old'}), [1]);
      expect(await File(shared('https://next')).exists(), isFalse);
    });

    test('copies an old file a file provider still reads', () async {
      const url = 'https://sub.test/blanc';
      final old = '1/proxies/${url.toMd5()}';
      await write(old, 'old');
      await claimProviderCache(
        root.path,
        1,
        {
          ...config({'b': url}),
          'rule-providers': {
            'm': {'type': 'file', 'path': join(root.path, old)},
          },
        },
        [1],
      );
      expect(await File(shared(url)).readAsString(), 'old');
      expect(await file(old).readAsString(), 'old');
    });

    test('sweeps nothing when the index cannot be read', () async {
      await claimProviderCache(root.path, 2, config({'b': 'https://a'}), [2]);
      await put(shared('https://a'), 'x');
      await write('index.json', '{broken');
      await expectLater(
        claimProviderCache(root.path, 1, config({}), [1, 2]),
        throwsFormatException,
      );
      expect(await File(shared('https://a')).exists(), isTrue);
    });

    test('forgets profiles that are gone', () async {
      await claimProviderCache(root.path, 7, config({'b': 'https://a'}), [7]);
      await put(shared('https://a'), 'x');
      await claimProviderCache(root.path, 1, config({}), [1]);
      expect(await File(shared('https://a')).exists(), isFalse);
    });
  });
}
