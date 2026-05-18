// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

// Pre-fetch libraries with SHA-256 + GPG verification, then hand off to
// Gradle. The Gradle download tasks are SHA-pinned too; this script's
// pre-fetch is the GPG defense-in-depth layer Gradle alone cannot provide.

const _signerFpr = '1139C91B6525883E6783DCF04A94DA488A4C5033';
const _signerPubKeyPath = 'scripts/oviron-signing.pub.asc';

const _libmihomoVersion = '0.1.0';
const _libmihomoSha256 =
    '017f15e69130066490e7e67ffa2b805f9cd5d696fa672d73752e3188ec8b18f2';

const _libbyedpiVersion = '0.1.0';
const _libbyedpiSha256 =
    '3308b6408f6dc944341368d53dc62b471ae1131424a749a105f25989530155c9';

class _PinnedAar {
  final String label;
  final String version;
  final String sha256;
  final String releaseRepo;
  final String moduleBuildLibsDir;

  _PinnedAar({
    required this.label,
    required this.version,
    required this.sha256,
    required this.releaseRepo,
    required this.moduleBuildLibsDir,
  });

  String get fileName => 'lib$label-android-v$version.aar';
  String get url =>
      'https://github.com/$releaseRepo/releases/download/v$version/$fileName';
}

enum Arch { amd64, arm64, arm }

class BuildItem {
  final Arch arch;
  final String flutterTarget;

  const BuildItem({required this.arch, required this.flutterTarget});
}

class Build {
  static const List<BuildItem> androidItems = [
    BuildItem(arch: Arch.arm, flutterTarget: 'android-arm'),
    BuildItem(arch: Arch.arm64, flutterTarget: 'android-arm64'),
    BuildItem(arch: Arch.amd64, flutterTarget: 'android-x64'),
  ];

  static String get distPath => join(current, 'dist');

  static final List<_PinnedAar> _aars = [
    _PinnedAar(
      label: 'mihomo',
      version: _libmihomoVersion,
      sha256: _libmihomoSha256,
      releaseRepo: 'oviron/libmihomo-android',
      moduleBuildLibsDir: 'android/core/libs',
    ),
    _PinnedAar(
      label: 'byedpi',
      version: _libbyedpiVersion,
      sha256: _libbyedpiSha256,
      releaseRepo: 'oviron/libbyedpi-android',
      moduleBuildLibsDir: 'android/app/libs',
    ),
  ];

  static Future<void> exec(
    List<String> executable, {
    String? name,
    Map<String, String>? environment,
    String? workingDirectory,
    bool runInShell = true,
  }) async {
    if (name != null) print('run $name');
    print('exec: ${executable.join(' ')}');
    final process = await Process.start(
      executable[0],
      executable.sublist(1),
      environment: environment,
      workingDirectory: workingDirectory,
      runInShell: runInShell,
    );
    process.stdout.listen((data) => stdout.write(utf8.decode(data)));
    process.stderr.listen((data) => stderr.write(utf8.decode(data)));
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw '${name ?? executable.first} failed (exit $exitCode)';
    }
  }

  static Future<void> fetchAars() async {
    for (final aar in _aars) {
      await _fetchAar(aar);
    }
  }

  static Future<void> _fetchAar(_PinnedAar pinned) async {
    final libsDir = Directory(join(current, pinned.moduleBuildLibsDir));
    libsDir.createSync(recursive: true);

    // Gradle uses fileTree("libs") { include("lib<label>-android-v*.aar") } —
    // setup.dart is the single source of version truth. Sweep any stale .aar
    // (and its .asc) so a downgrade or version change can't leave two .aars
    // matching the include glob and double-linking in the APK.
    for (final f in libsDir.listSync()) {
      final name = f.uri.pathSegments.last;
      if (f is File &&
          name.startsWith('lib${pinned.label}-android-v') &&
          (name.endsWith('.aar') || name.endsWith('.aar.asc')) &&
          name != pinned.fileName &&
          name != '${pinned.fileName}.asc') {
        f.deleteSync();
        print('removed stale ${f.path}');
      }
    }

    final target = File(join(libsDir.path, pinned.fileName));
    final cached =
        target.existsSync() && await _verifySha256(target, pinned.sha256);
    if (!cached) {
      print('fetching ${pinned.url}');
      await _download(pinned.url, target);
      if (!await _verifySha256(target, pinned.sha256)) {
        final actual = await _sha256Hex(target);
        await target.delete();
        throw 'lib${pinned.label} SHA-256 mismatch: '
            'expected ${pinned.sha256}, got $actual';
      }
    } else {
      print('lib${pinned.label} v${pinned.version} cached, SHA-256 OK');
    }

    final asc = File('${target.path}.asc');
    if (!asc.existsSync()) {
      print('fetching ${pinned.url}.asc');
      await _download('${pinned.url}.asc', asc);
    }
    try {
      await _verifyGpg(target, asc);
    } catch (_) {
      // Stale or corrupt .asc would otherwise loop forever — drop it so the
      // next run re-downloads. Re-throw to surface the failure to the caller.
      if (asc.existsSync()) await asc.delete();
      rethrow;
    }
  }

  static Future<bool> _verifySha256(File f, String expected) async {
    final actual = await _sha256Hex(f);
    return actual.toLowerCase() == expected.toLowerCase();
  }

  static Future<String> _sha256Hex(File f) async {
    return sha256.convert(await f.readAsBytes()).toString();
  }

  static Future<void> _verifyGpg(File aar, File asc) async {
    final pubKey = File(join(current, _signerPubKeyPath));
    if (!pubKey.existsSync()) {
      throw 'pinned signer pubkey missing: ${pubKey.path}';
    }
    final gpgHome = await Directory.systemTemp.createTemp('flclash-gpg-');
    try {
      final env = {'GNUPGHOME': gpgHome.path};
      final import = await Process.run('gpg', [
        '--batch',
        '--quiet',
        '--import',
        pubKey.path,
      ], environment: env);
      if (import.exitCode != 0) {
        throw 'gpg --import failed: ${import.stderr}';
      }

      final verify = await Process.run('gpg', [
        '--batch',
        '--status-fd',
        '1',
        '--no-tty',
        '--verify',
        asc.path,
        aar.path,
      ], environment: env);
      final status = '${verify.stdout}\n${verify.stderr}';
      if (verify.exitCode != 0 ||
          !status.contains('GOODSIG') ||
          !status.contains(_signerFpr)) {
        throw 'GPG verification failed for ${aar.path}:\n$status';
      }
      print('  GPG signature verified by $_signerFpr');
    } finally {
      await gpgHome.delete(recursive: true);
    }
  }

  static Future<void> _download(String url, File target) async {
    target.parent.createSync(recursive: true);
    final partial = File('${target.path}.part');
    if (partial.existsSync()) {
      await partial.delete();
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 60);
    try {
      var attempt = 0;
      var currentUri = Uri.parse(url);
      while (true) {
        attempt++;
        final req = await client.getUrl(currentUri);
        final resp = await req.close();
        if (resp.statusCode == 301 ||
            resp.statusCode == 302 ||
            resp.statusCode == 307 ||
            resp.statusCode == 308) {
          if (attempt > 5) {
            throw 'too many redirects fetching $url';
          }
          final next = resp.headers.value('location');
          if (next == null) {
            throw 'redirect without Location from $currentUri';
          }
          currentUri = currentUri.resolve(next);
          continue;
        }
        if (resp.statusCode != 200) {
          throw 'HTTP ${resp.statusCode} from $currentUri';
        }
        final sink = partial.openWrite();
        try {
          await resp.pipe(sink);
        } catch (e) {
          await sink.close();
          if (partial.existsSync()) await partial.delete();
          rethrow;
        }
        await partial.rename(target.path);
        return;
      }
    } finally {
      client.close();
    }
  }
}

class BuildAndroidCommand extends Command<void> {
  BuildAndroidCommand() {
    argParser.addOption(
      'arch',
      valueHelp: Build.androidItems.map((e) => e.arch.name).join(','),
      help:
          'Limit final APK split to one Android arch (default: build all '
          'three).',
    );
    argParser.addOption(
      'env',
      valueHelp: 'pre,stable',
      help: 'APP_ENV value baked into env.json (default: pre)',
    );
    argParser.addOption(
      'flavor',
      allowed: ['classic', 'bydpi'],
      defaultsTo: 'classic',
      help: 'Android product flavor',
    );
  }

  @override
  String get name => 'android';

  @override
  String get description => 'build Android application (APK split-per-abi)';

  Future<void> _writeEnvFile(String env) async {
    final data = {'APP_ENV': env};
    final envFile = File(join(current, 'env.json'));
    await envFile.create();
    await envFile.writeAsString(json.encode(data));
  }

  String _readPubspecVersion() {
    final pubspec = File(join(current, 'pubspec.yaml')).readAsStringSync();
    final yaml = loadYaml(pubspec) as YamlMap;
    final raw = yaml['version'].toString();
    return raw.split('+').first;
  }

  Future<void> _copyApks(List<BuildItem> items, String flavor) async {
    final version = _readPubspecVersion();
    final flutterApkDir = Directory(
      join(current, 'build', 'app', 'outputs', 'flutter-apk'),
    );
    final dist = Directory(Build.distPath);
    if (!dist.existsSync()) dist.createSync(recursive: true);

    for (final item in items) {
      final src = File(
        join(
          flutterApkDir.path,
          'app-${_archName(item.arch)}-$flavor-release.apk',
        ),
      );
      if (!src.existsSync()) {
        throw 'Missing Flutter APK: ${src.path}';
      }
      final dst = File(
        join(
          dist.path,
          'FlClash-$flavor-$version-android-${_archName(item.arch)}.apk',
        ),
      );
      await src.copy(dst.path);
      print('copied ${src.path} -> ${dst.path}');
    }
  }

  static String _archName(Arch a) => switch (a) {
    Arch.arm => 'armeabi-v7a',
    Arch.arm64 => 'arm64-v8a',
    Arch.amd64 => 'x86_64',
  };

  @override
  Future<void> run() async {
    final archName = argResults?['arch'] as String?;
    final env = (argResults?['env'] as String?) ?? 'pre';
    final flavor = argResults?['flavor'] as String? ?? 'classic';

    Arch? arch;
    if (archName != null) {
      final match = Build.androidItems
          .where((e) => e.arch.name == archName)
          .toList();
      if (match.isEmpty) throw 'Invalid arch: $archName';
      arch = match.first.arch;
    }

    await Build.fetchAars();
    await _writeEnvFile(env);

    final items = arch == null
        ? Build.androidItems
        : Build.androidItems.where((e) => e.arch == arch).toList();
    final flutterTargets = items.map((e) => e.flutterTarget).join(',');

    await Build.exec([
      'flutter',
      'build',
      'apk',
      '--release',
      '--split-per-abi',
      '--flavor',
      flavor,
      '--target-platform',
      flutterTargets,
      '--dart-define-from-file=env.json',
      '--dart-define=BYDPI=${flavor == 'bydpi'}',
    ], name: 'flutter build apk ($flavor)');

    await _copyApks(items, flavor);
  }
}

Future<void> main(List<String> args) async {
  final runner = CommandRunner<void>('setup', 'build FlClash (Android)');
  runner.addCommand(BuildAndroidCommand());
  await runner.run(args);
}
