import 'package:fl_clash/byedpi/geoip_list.dart';
import 'package:fl_clash/byedpi/host_list.dart';
import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/byedpi.dart';
import 'package:fl_clash/views/setting/widgets/byedpi_geoip_list_editor.dart';
import 'package:fl_clash/views/setting/widgets/byedpi_host_list_editor.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ByeDpiView extends ConsumerWidget {
  const ByeDpiView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(byeDpiSettingsProvider);

    return BaseScaffold(
      title: appLocalizations.byedpiTitle,
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.toggle_on_outlined),
            title: Text(appLocalizations.byedpiEnable),
            value: settings.enabled,
            onChanged: (v) =>
                ref.read(byeDpiSettingsProvider.notifier).setEnabled(v),
          ),
          const Divider(height: 0),
          if (settings.enabled) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                appLocalizations.byedpiMode,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            RadioGroup<ByeDpiMode>(
              groupValue: settings.mode,
              onChanged: (v) {
                if (v != null) {
                  ref.read(byeDpiSettingsProvider.notifier).setMode(v);
                }
              },
              child: Column(
                children: [
                  RadioListTile<ByeDpiMode>(
                    title: Text(appLocalizations.byedpiModeAuto),
                    value: ByeDpiMode.auto,
                  ),
                  if (settings.mode == ByeDpiMode.auto) ...[
                    SwitchListTile(
                      contentPadding: const EdgeInsets.only(left: 32, right: 16),
                      title: Text(appLocalizations.byedpiFallback),
                      value: settings.fallbackEnabled,
                      onChanged: (v) => ref
                          .read(byeDpiSettingsProvider.notifier)
                          .setFallbackEnabled(v),
                    ),
                    if (settings.fallbackEnabled)
                      _FallbackGroupTile(selected: settings.fallbackGroup),
                  ],
                  RadioListTile<ByeDpiMode>(
                    title: Text(appLocalizations.byedpiModeManual),
                    value: ByeDpiMode.manual,
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            _CliArgsField(cliArgs: settings.cliArgs),
            _PortField(port: settings.port),
            const Divider(height: 0),
            SwitchListTile(
              secondary: const Icon(Icons.network_check_outlined),
              title: Text(appLocalizations.byedpiUdpEnabled),
              subtitle: Text(appLocalizations.byedpiUdpEnabledHint),
              value: settings.udpEnabled,
              onChanged: (v) => ref
                  .read(byeDpiSettingsProvider.notifier)
                  .setUdpEnabled(v),
            ),
            if (settings.udpEnabled)
              _UdpFakeCountField(count: settings.udpFakeCount),
            const Divider(height: 0),
            _HostListTile(),
            _GeoipListTile(),
          ],
        ],
      ),
    );
  }
}

class _FallbackGroupTile extends ConsumerWidget {
  final String selected;
  const _FallbackGroupTile({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);
    final names = groups.map((g) => g.name).where((n) => n.isNotEmpty).toList();

    if (names.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 16, 8),
        child: Text(
          appLocalizations.byedpiNoProxyGroups,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final effective = names.contains(selected) ? selected : names.first;
    if (effective != selected) {
      Future.microtask(() => ref
          .read(byeDpiSettingsProvider.notifier)
          .setFallbackGroup(effective));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 16, 8),
      child: Row(
        children: [
          Text(
            appLocalizations.byedpiFallbackProxy,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: effective,
            items: names
                .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                ref
                    .read(byeDpiSettingsProvider.notifier)
                    .setFallbackGroup(v);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _CliArgsField extends ConsumerStatefulWidget {
  final String cliArgs;
  const _CliArgsField({required this.cliArgs});

  @override
  ConsumerState<_CliArgsField> createState() => _CliArgsFieldState();
}

class _CliArgsFieldState extends ConsumerState<_CliArgsField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.cliArgs);
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_CliArgsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cliArgs != widget.cliArgs &&
        _controller.text != widget.cliArgs) {
      _controller.text = widget.cliArgs;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) return;
    final next = _controller.text;
    if (next == widget.cliArgs) return;
    ref.read(byeDpiSettingsProvider.notifier).setCliArgs(next);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: appLocalizations.byedpiCliArgs,
          hintText: appLocalizations.byedpiCliArgsHint,
        ),
        style: const TextStyle(fontFamily: 'JetBrainsMono'),
        maxLines: 3,
        minLines: 1,
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}

class _PortField extends ConsumerStatefulWidget {
  final int port;
  const _PortField({required this.port});

  @override
  ConsumerState<_PortField> createState() => _PortFieldState();
}

class _PortFieldState extends ConsumerState<_PortField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.port.toString());
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_PortField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.port != widget.port) {
      final s = widget.port.toString();
      if (_controller.text != s) _controller.text = s;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) return;
    final v = int.tryParse(_controller.text);
    if (v == null || v == widget.port) return;
    ref.read(byeDpiSettingsProvider.notifier).setPort(v);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(labelText: appLocalizations.byedpiPort),
        keyboardType: TextInputType.number,
      ),
    );
  }
}

class _HostListTile extends StatefulWidget {
  @override
  State<_HostListTile> createState() => _HostListTileState();
}

class _HostListTileState extends State<_HostListTile> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    countHosts().then((n) {
      if (mounted) setState(() => _count = n);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.list_alt_outlined),
      title: Text(appLocalizations.byedpiHostList),
      subtitle: Text('$_count hosts'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ByeDpiHostListEditor(),
        ),
      ),
    );
  }
}

class _GeoipListTile extends StatefulWidget {
  @override
  State<_GeoipListTile> createState() => _GeoipListTileState();
}

class _GeoipListTileState extends State<_GeoipListTile> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    countGeoipCategories().then((n) {
      if (mounted) setState(() => _count = n);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.public_outlined),
      title: Text(appLocalizations.byedpiGeoipList),
      subtitle: Text('$_count categories'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ByeDpiGeoipListEditor(),
        ),
      ),
    );
  }
}

class _UdpFakeCountField extends ConsumerStatefulWidget {
  final int count;
  const _UdpFakeCountField({required this.count});

  @override
  ConsumerState<_UdpFakeCountField> createState() => _UdpFakeCountFieldState();
}

class _UdpFakeCountFieldState extends ConsumerState<_UdpFakeCountField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.count.toString());
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_UdpFakeCountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      final s = widget.count.toString();
      if (_controller.text != s) _controller.text = s;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) return;
    final v = int.tryParse(_controller.text);
    if (v == null || v == widget.count) return;
    ref.read(byeDpiSettingsProvider.notifier).setUdpFakeCount(v);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: appLocalizations.byedpiUdpFakeCount,
          helperText: appLocalizations.byedpiUdpFakeCountHint,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
