import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/byedpi/strategy_args.dart';
import 'package:fl_clash/byedpi/strategy_update.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/byedpi.dart';
import 'package:fl_clash/views/setting/byedpi_test.dart';
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
                      contentPadding: const EdgeInsets.only(
                        left: 32,
                        right: 16,
                      ),
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
            _PresetPicker(preset: settings.preset),
            if (settings.preset == kByeDpiCustomId)
              _CliArgsField(cliArgs: settings.cliArgs)
            else
              _PresetArgsPreview(preset: settings.preset),
            const _StrategyUpdateTile(),
            ListTile(
              leading: const Icon(Icons.speed_outlined),
              title: Text(appLocalizations.byedpiTestTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ByeDpiTestView())),
            ),
            const _RestartButton(),
            _PortField(port: settings.port),
          ],
        ],
      ),
    );
  }
}

class _PresetPicker extends ConsumerWidget {
  final String preset;
  const _PresetPicker({required this.preset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategies = ref.watch(byeDpiStrategiesProvider).value ?? const [];
    final items = <DropdownMenuItem<String>>[
      for (final s in strategies)
        DropdownMenuItem(value: s.id, child: Text(s.label)),
      DropdownMenuItem(
        value: kByeDpiCustomId,
        child: Text(appLocalizations.byedpiPresetCustom),
      ),
    ];
    // The list resolves async; until then `preset` may not be an item yet —
    // null the value to avoid a Dropdown assertion.
    final hasValue = items.any((i) => i.value == preset);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: appLocalizations.byedpiPreset,
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: hasValue ? preset : null,
            items: items,
            onChanged: (v) {
              if (v != null) {
                ref.read(byeDpiSettingsProvider.notifier).setPreset(v);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _RestartButton extends StatefulWidget {
  const _RestartButton();

  @override
  State<_RestartButton> createState() => _RestartButtonState();
}

class _RestartButtonState extends State<_RestartButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.restart_alt),
          label: Text(appLocalizations.byedpiRestart),
          onPressed: _busy ? null : _onPressed,
        ),
      ),
    );
  }

  Future<void> _onPressed() async {
    final svc = service;
    if (svc == null) return;
    setState(() => _busy = true);
    final ok = await svc.restartByeDpi();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? appLocalizations.byedpiRestartOk
              : appLocalizations.byedpiRestartFail,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _PresetArgsPreview extends ConsumerWidget {
  final String preset;
  const _PresetArgsPreview({required this.preset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategies = ref.watch(byeDpiStrategiesProvider).value ?? const [];
    final args = strategies
        .firstWhere(
          (s) => s.id == preset,
          orElse: () => const ByeDpiStrategy(id: '', label: '', args: ''),
        )
        .args;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SelectableText(
        args,
        style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12),
      ),
    );
  }
}

class _StrategyUpdateTile extends ConsumerStatefulWidget {
  const _StrategyUpdateTile();

  @override
  ConsumerState<_StrategyUpdateTile> createState() =>
      _StrategyUpdateTileState();
}

class _StrategyUpdateTileState extends ConsumerState<_StrategyUpdateTile> {
  bool _busy = false;
  DateTime? _last;

  @override
  void initState() {
    super.initState();
    strategiesLastUpdate().then((v) {
      if (mounted) setState(() => _last = v);
    });
  }

  Future<void> _update() async {
    setState(() => _busy = true);
    String msg;
    try {
      final count = await updateStrategiesFromRemote();
      ref.invalidate(byeDpiStrategiesProvider);
      _last = await strategiesLastUpdate();
      msg = '${appLocalizations.byedpiUpdateOk} ($count)';
    } catch (e) {
      final detail = e.toString();
      msg =
          '${appLocalizations.byedpiUpdateFail}: '
          '${detail.length > 120 ? detail.substring(0, 120) : detail}';
    }
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
    );
  }

  Future<void> _reset() async {
    await resetStrategyList();
    ref.invalidate(byeDpiStrategiesProvider);
    if (!mounted) return;
    setState(() => _last = null);
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _last == null
        ? appLocalizations.byedpiStrategiesNever
        : _last!.toLocal().toString().split('.').first;
    return ListTile(
      leading: const Icon(Icons.cloud_download_outlined),
      title: Text(appLocalizations.byedpiUpdateStrategies),
      subtitle: Text(subtitle),
      trailing: _busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'reset') _reset();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'reset',
                  child: Text(appLocalizations.byedpiResetStrategies),
                ),
              ],
            ),
      onTap: _busy ? null : _update,
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
      Future.microtask(
        () => ref
            .read(byeDpiSettingsProvider.notifier)
            .setFallbackGroup(effective),
      );
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
                ref.read(byeDpiSettingsProvider.notifier).setFallbackGroup(v);
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
