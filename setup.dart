// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart' as archive;
import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

// Pinned mihomo bridge: bumped together with libmihomo-android release.
const _libmihomoVersion = '0.1.0';
const _libmihomoSha256 =
    'c84c4a9a3d1cccb12bc84f58518cf0b1d9fc74da13aa2571040456b464be32be';
const _libmihomoUrl =
    'https://github.com/oviron/libmihomo-android/releases/download/'
    'v$_libmihomoVersion/libmihomo-android-v$_libmihomoVersion.aar';

enum Arch { amd64, arm64, arm }

class BuildItem {
  final Arch arch;
  final String archName;
  final String flutterTarget;

  const BuildItem({
    required this.arch,
    required this.archName,
    required this.flutterTarget,
  });
}

class Build {
  static const List<BuildItem> androidItems = [
    BuildItem(
      arch: Arch.arm,
      archName: 'armeabi-v7a',
      flutterTarget: 'android-arm',
    ),
    BuildItem(
      arch: Arch.arm64,
      archName: 'arm64-v8a',
      flutterTarget: 'android-arm64',
    ),
    BuildItem(
      arch: Arch.amd64,
      archName: 'x86_64',
      flutterTarget: 'android-x64',
    ),
  ];

  static String get appName => 'FlClash';
  static String get libName => 'libclash';
  static String get outDir => join(current, libName);
  static String get distPath => join(current, 'dist');
  static String get _cacheDir =>
      join(current, '.dart_tool', 'libmihomo-android');

  static Future<void> exec(
    List<String> executable, {
    String? name,
    Map<String, String>? environment,
    String? workingDirectory,
    bool runInShell = true,
  }) async {
    if (name != null) print('run $name');
    print('exec: ${executable.join(' ')}');
    if (environment != null) print('env: $environment');
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

  /// Downloads pinned libmihomo-android .aar, verifies SHA-256, extracts
  /// libclash.so for ALL supported ABIs into libclash/android/<abi>/.
  /// Idempotent: keeps the cached .aar across runs as long as its hash matches.
  /// `arch` is ignored here — we always populate all ABIs because CMake/NDK
  /// builds libcore.so per defaultConfig ABI regardless of the flutter
  /// `--target-platform` selection at APK assembly time.
  static Future<void> setupLibmihomo({Arch? arch}) async {
    final items = androidItems;

    await Directory(_cacheDir).create(recursive: true);
    final aarFile = File(
      join(_cacheDir, 'libmihomo-android-v$_libmihomoVersion.aar'),
    );

    final cached = aarFile.existsSync() &&
        await _verifySha256(aarFile, _libmihomoSha256);
    if (cached) {
      print(
        'libmihomo-android v$_libmihomoVersion cached, SHA-256 verified',
      );
    } else {
      print('downloading $_libmihomoUrl');
      await _download(_libmihomoUrl, aarFile);
      if (!await _verifySha256(aarFile, _libmihomoSha256)) {
        final actual = await _sha256Hex(aarFile);
        await aarFile.delete();
        throw 'libmihomo .aar SHA-256 mismatch:\n'
            '  expected $_libmihomoSha256\n'
            '  actual   $actual';
      }
      print(
        'downloaded ${aarFile.lengthSync()} bytes, '
        'SHA-256 verified: $_libmihomoSha256',
      );
    }

    final androidOutDir = Directory(join(outDir, 'android'));
    if (androidOutDir.existsSync()) {
      androidOutDir.deleteSync(recursive: true);
    }
    androidOutDir.createSync(recursive: true);

    final aar = archive.ZipDecoder().decodeBytes(aarFile.readAsBytesSync());
    for (final item in items) {
      final entryName = 'jni/${item.archName}/$libName.so';
      final entry = aar.findFile(entryName);
      if (entry == null) {
        throw '.aar missing entry: $entryName';
      }
      final outFile = File(
        join(androidOutDir.path, item.archName, '$libName.so'),
      );
      outFile.parent.createSync(recursive: true);
      outFile.writeAsBytesSync(entry.content as List<int>);
      print(
        'extracted $entryName -> ${outFile.path} (${entry.size} bytes)',
      );
    }
  }

  static Future<bool> _verifySha256(File f, String expected) async {
    final actual = await _sha256Hex(f);
    return actual.toLowerCase() == expected.toLowerCase();
  }

  static Future<String> _sha256Hex(File f) async {
    return sha256.convert(await f.readAsBytes()).toString();
  }

  static Future<void> _download(String url, File target) async {
    target.parent.createSync(recursive: true);
    final client = HttpClient();
    try {
      var attempt = 0;
      var current = Uri.parse(url);
      while (true) {
        attempt++;
        final req = await client.getUrl(current);
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
            throw 'redirect without Location from $current';
          }
          current = current.resolve(next);
          continue;
        }
        if (resp.statusCode != 200) {
          throw 'HTTP ${resp.statusCode} from $current';
        }
        final sink = target.openWrite();
        await resp.pipe(sink);
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
      help: 'Limit build to a single Android arch (default: all)',
    );
    argParser.addOption(
      'env',
      valueHelp: 'pre,stable',
      help: 'APP_ENV value baked into env.json (default: pre)',
    );
    argParser.addOption(
      'out',
      valueHelp: 'app,core',
      help: 'Build target: app (apk) or core (download libclash.so only)',
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
          'app-${item.archName}-$flavor-release.apk',
        ),
      );
      if (!src.existsSync()) {
        throw 'Missing Flutter APK: ${src.path}';
      }
      final dst = File(
        join(
          dist.path,
          'FlClash-$flavor-$version-android-${item.archName}.apk',
        ),
      );
      await src.copy(dst.path);
      print('copied ${src.path} -> ${dst.path}');
    }
  }

  @override
  Future<void> run() async {
    final archName = argResults?['arch'] as String?;
    final env = (argResults?['env'] as String?) ?? 'pre';
    final out = (argResults?['out'] as String?) ?? 'app';
    final flavor = argResults?['flavor'] as String? ?? 'classic';

    Arch? arch;
    if (archName != null) {
      final match = Build.androidItems
          .where((e) => e.arch.name == archName)
          .toList();
      if (match.isEmpty) throw 'Invalid arch: $archName';
      arch = match.first.arch;
    }

    await Build.setupLibmihomo(arch: arch);
    await _writeEnvFile(env);

    if (out != 'app') return;

    final items = arch == null
        ? Build.androidItems
        : Build.androidItems.where((e) => e.arch == arch).toList();
    final flutterTargets = items.map((e) => e.flutterTarget).join(',');

    await Build.exec(
      [
        'flutter', 'build', 'apk', '--release',
        '--split-per-abi',
        '--flavor', flavor,
        '--target-platform', flutterTargets,
        '--dart-define-from-file=env.json',
        '--dart-define=BYDPI=${flavor == 'bydpi'}',
      ],
      name: 'flutter build apk ($flavor)',
    );

    await _copyApks(items, flavor);
  }
}

Future<void> main(List<String> args) async {
  final runner = CommandRunner<void>('setup', 'build FlClash (Android)');
  runner.addCommand(BuildAndroidCommand());
  await runner.run(args);
}
