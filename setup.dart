// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

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
    BuildItem(arch: Arch.arm, archName: 'armeabi-v7a', flutterTarget: 'android-arm'),
    BuildItem(arch: Arch.arm64, archName: 'arm64-v8a', flutterTarget: 'android-arm64'),
    BuildItem(arch: Arch.amd64, archName: 'x86_64', flutterTarget: 'android-x64'),
  ];

  static String get appName => 'FlClash';
  static String get libName => 'libclash';
  static String get outDir => join(current, libName);
  static String get _coreDir => join(current, 'core');
  static String get distPath => join(current, 'dist');
  static String get tags => 'with_gvisor,cmfa';

  static String _getCc(String archName) {
    final ndk = Platform.environment['ANDROID_NDK'];
    assert(ndk != null, 'ANDROID_NDK env var must be set');
    final prebuiltDir = Directory(join(ndk!, 'toolchains', 'llvm', 'prebuilt'));
    final prebuiltDirList = prebuiltDir
        .listSync()
        .where((file) => !basename(file.path).startsWith('.'))
        .toList();
    const map = {
      'armeabi-v7a': 'armv7a-linux-androideabi21-clang',
      'arm64-v8a': 'aarch64-linux-android21-clang',
      'x86_64': 'x86_64-linux-android21-clang',
    };
    return join(prebuiltDirList.first.path, 'bin', map[archName]!);
  }

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

  static Future<void> buildCore({Arch? arch}) async {
    final items = arch == null
        ? androidItems
        : androidItems.where((e) => e.arch == arch).toList();

    final targetOutFilePath = join(outDir, 'android');
    final targetOutFile = File(targetOutFilePath);
    if (await targetOutFile.exists()) {
      await targetOutFile.delete(recursive: true);
      await Directory(targetOutFilePath).create(recursive: true);
    }

    for (final item in items) {
      final outFilePath = join(targetOutFilePath, item.archName);
      final dir = Directory(outFilePath);
      if (dir.existsSync()) dir.deleteSync(recursive: true);
      final realOutPath = join(outFilePath, '$libName.so');

      final env = <String, String>{
        ...Platform.environment,
        'GOOS': 'android',
        'GOARCH': item.arch.name,
        'CGO_ENABLED': '1',
        'CC': _getCc(item.archName),
        'CFLAGS': '-O3 -Werror',
      };
      await exec(
        [
          'go', 'build',
          '-ldflags=-w -s',
          '-tags=$tags',
          '-buildmode=c-shared',
          '-o', realOutPath,
        ],
        name: 'build core ${item.archName}',
        environment: env,
        workingDirectory: _coreDir,
      );
      await _adjustLibOut(
        targetOutFilePath: targetOutFilePath,
        outFilePath: outFilePath,
        archName: item.archName,
      );
    }
  }

  static Future<void> _adjustLibOut({
    required String targetOutFilePath,
    required String outFilePath,
    required String archName,
  }) async {
    final includesPath = join(targetOutFilePath, 'includes');
    final realOutPath = join(includesPath, archName);
    await Directory(realOutPath).create(recursive: true);
    final targetOutFiles = Directory(outFilePath).listSync();
    final coreFiles = Directory(_coreDir).listSync();
    for (final file in [...targetOutFiles, ...coreFiles]) {
      if (!file.path.endsWith('.h')) continue;
      final targetFilePath = join(realOutPath, basename(file.path));
      final realFile = File(file.path);
      await realFile.copy(targetFilePath);
      if (coreFiles.contains(file)) continue;
      await realFile.delete();
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
      help: 'Build target: app (apk) or core (libclash.so only)',
    );
    argParser.addOption(
      'flavor',
      valueHelp: 'classic,bydpi',
      help: 'Android product flavor (default: classic)',
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
    // version: 0.8.92+2026020201 → 0.8.92
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
      final src = File(join(flutterApkDir.path, 'app-$flavor-${item.archName}-release.apk'));
      if (!src.existsSync()) {
        throw 'Missing Flutter APK: ${src.path}';
      }
      final dst = File(join(dist.path, 'FlClash-$flavor-$version-android-${item.archName}.apk'));
      await src.copy(dst.path);
      print('copied ${src.path} -> ${dst.path}');
    }
  }

  @override
  Future<void> run() async {
    final archName = argResults?['arch'] as String?;
    final env = (argResults?['env'] as String?) ?? 'pre';
    final out = (argResults?['out'] as String?) ?? 'app';
    final flavor = (argResults?['flavor'] as String?) ?? 'classic';

    if (!['classic', 'bydpi'].contains(flavor)) {
      throw 'Invalid flavor: $flavor. Must be one of: classic, bydpi';
    }

    Arch? arch;
    if (archName != null) {
      final match = Build.androidItems
          .where((e) => e.arch.name == archName)
          .toList();
      if (match.isEmpty) throw 'Invalid arch: $archName';
      arch = match.first.arch;
    }

    await Build.buildCore(arch: arch);
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
