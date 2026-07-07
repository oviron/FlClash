import 'package:fl_clash/library/model.dart';
import 'package:fl_clash/library/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

String _coreTitle(String label) => 'mihomo';

String _sizeLabel(int bytes) => '${(bytes / 1048576).toStringAsFixed(1)} MB';

class LibraryVersionView extends ConsumerWidget {
  const LibraryVersionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = [kLibMihomo];
    return BaseScaffold(
      title: Intl.message('Library version', name: 'libraryVersion'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: Intl.message('Refresh', name: 'libRefresh'),
          onPressed: () {
            for (final l in labels) {
              ref.invalidate(libraryReleasesProvider(l));
            }
          },
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [for (final label in labels) _CoreSection(label: label)],
      ),
    );
  }
}

class _CoreSection extends ConsumerStatefulWidget {
  final String label;

  const _CoreSection({required this.label});

  @override
  ConsumerState<_CoreSection> createState() => _CoreSectionState();
}

class _CoreSectionState extends ConsumerState<_CoreSection> {
  final Set<String> _busy = {};

  Future<void> _guard(String key, Future<void> Function() action) async {
    if (_busy.contains(key)) return;
    setState(() => _busy.add(key));
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy.remove(key));
    }
  }

  Future<bool> _confirmSwitch() async {
    final ok = await globalState.showMessage(
      title: Intl.message('Switch core version', name: 'libSwitchTitle'),
      message: TextSpan(
        text: Intl.message(
          'Switching reloads the engine and drops your current connection. Continue?',
          name: 'libSwitchBody',
        ),
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final expected = ref.watch(libraryExpectedAbiProvider).value ?? const {};
    final deviceAbi = ref.watch(libraryDeviceAbiProvider).value ?? '';
    final active =
        (ref.watch(activeLibraryDirsProvider).value ?? const {})[label];
    final installed = (ref.watch(installedLibrariesProvider).value ?? const [])
        .where((e) => e.label == label)
        .toList();
    final releasesAsync = ref.watch(libraryReleasesProvider(label));
    final controller = ref.read(libraryControllerProvider.notifier);
    final expectedAbi = expected[label];

    final installedVersions = installed.map((e) => e.version).toSet();
    final bundled =
        (ref.watch(libraryBundledVersionsProvider).value ?? const {})[label];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListHeader(title: _coreTitle(label)),
        ListItem(
          leading: const Icon(Icons.check_circle_outline),
          title: Text(Intl.message('Active', name: 'libActive')),
          subtitle: Text(
            active != null
                ? _versionFromDir(active)
                : (bundled != null && bundled.isNotEmpty
                      ? '${Intl.message('Bundled', name: 'libBundledShort')} · v$bundled'
                      : Intl.message('Bundled (default)', name: 'libBundled')),
          ),
          trailing: active == null
              ? null
              : TextButton(
                  onPressed: _busy.isNotEmpty
                      ? null
                      : () => _guard('reset', () async {
                          if (!await _confirmSwitch()) return;
                          await controller.resetToBundled(
                            label,
                            wasRunning: ref.read(isStartProvider),
                          );
                        }),
                  child: Text(
                    Intl.message('Reset to bundled', name: 'libReset'),
                  ),
                ),
        ),
        if (installed.isNotEmpty) ...[
          const Divider(height: 0),
          ListHeader(title: Intl.message('Installed', name: 'libInstalled')),
          for (final lib in installed)
            ListItem(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text('v${lib.version}'),
              subtitle: Text(_sizeLabel(lib.sizeBytes)),
              trailing: _installedTrailing(lib, active, controller),
            ),
        ],
        const Divider(height: 0),
        ListHeader(title: Intl.message('Available', name: 'libAvailable')),
        releasesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => ListItem(
            leading: const Icon(Icons.error_outline),
            title: Text(
              Intl.message('Failed to load releases', name: 'libLoadError'),
            ),
            subtitle: Text('$e'),
          ),
          data: (releases) => Column(
            children: [
              for (final rel in releases)
                _releaseTile(
                  rel,
                  expectedAbi: expectedAbi,
                  deviceAbi: deviceAbi,
                  installed: installedVersions.contains(rel.version),
                  isBundled: bundled != null && rel.version == bundled,
                  controller: controller,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _installedTrailing(
    InstalledLibrary lib,
    String? active,
    LibraryController controller,
  ) {
    final isActive = active == lib.dir;
    if (isActive) {
      return Text(Intl.message('In use', name: 'libInUse'));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: _busy.isNotEmpty
              ? null
              : () => _guard('use-${lib.version}', () async {
                  if (!await _confirmSwitch()) return;
                  await controller.switchTo(
                    lib,
                    wasRunning: ref.read(isStartProvider),
                  );
                }),
          child: Text(Intl.message('Use', name: 'libUse')),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: Intl.message('Delete', name: 'libDelete'),
          onPressed: _busy.isNotEmpty
              ? null
              : () =>
                    _guard('del-${lib.version}', () => controller.delete(lib)),
        ),
      ],
    );
  }

  Widget _releaseTile(
    LibraryRelease rel, {
    required int? expectedAbi,
    required String deviceAbi,
    required bool installed,
    required bool isBundled,
    required LibraryController controller,
  }) {
    final compatible = rel.compatibleWith(
      expectedAbi: expectedAbi,
      deviceAbi: deviceAbi,
    );
    final subtitle = rel.coreVersion.isEmpty
        ? 'bridgeABI ${rel.bridgeAbi}'
        : '${rel.coreName} ${rel.coreVersion}';
    if (!compatible) {
      // rel ABI < app ABI: the core predates this app's bridge, so it can never
      // load here; "update the app" is wrong (the app is already newer).
      final tooOld = expectedAbi != null && rel.bridgeAbi < expectedAbi;
      final reason = tooOld
          ? Intl.message(
              'Incompatible (older core)',
              name: 'libIncompatibleOld',
            )
          : Intl.message('Requires app update', name: 'libNeedsUpdate');
      return ListItem(
        leading: const Icon(Icons.block),
        title: Text(
          'v${rel.version}',
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
        subtitle: Text(
          reason +
              (expectedAbi != null && rel.bridgeAbi != expectedAbi
                  ? ' (ABI ${rel.bridgeAbi})'
                  : ''),
        ),
      );
    }
    final busy = _busy.contains('dl-${rel.version}');
    return ListItem(
      leading: Icon(
        isBundled ? Icons.check_circle_outline : Icons.cloud_download_outlined,
      ),
      title: Text('v${rel.version}'),
      subtitle: Text(subtitle),
      trailing: isBundled
          ? Text(Intl.message('Bundled', name: 'libBundledTag'))
          : installed
          ? Text(Intl.message('Installed', name: 'libInstalledTag'))
          : busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: const Icon(Icons.download),
              onPressed: _busy.isNotEmpty
                  ? null
                  : () => _guard(
                      'dl-${rel.version}',
                      () => controller.downloadAndInstall(rel),
                    ),
            ),
    );
  }
}

String _versionFromDir(String dir) {
  final name = dir.split('/').last;
  final sep = name.indexOf('-v');
  return sep > 0 ? 'v${name.substring(sep + 2)}' : name;
}
