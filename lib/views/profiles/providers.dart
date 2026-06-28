import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/profile_routing/provider_spec.dart';
import 'package:fl_clash/profile_routing/provider_url.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _behaviors = ['domain', 'ipcidr', 'classical'];
const _formats = ['yaml', 'text', 'mrs'];

enum ProviderKind { proxy, rule }

/// Maps the editor's per-field strings onto a [ProviderSpec], emitting only the
/// fields the chosen source [type] exposes. [base]'s unknown keys (and unmanaged
/// `health-check` keys) are preserved.
ProviderSpec buildProviderSpec({
  required ProviderSpec base,
  required bool isRule,
  required String type,
  required String url,
  required String path,
  required String interval,
  required String? behavior,
  required String? format,
  required bool healthEnabled,
  required String healthUrl,
  required String healthInterval,
}) {
  final isHttp = type == 'http';
  final isFile = type == 'file';
  final next = base.copyWith(
    type: type,
    url: isHttp ? _trimOrNull(url) : null,
    path: isHttp ? null : _trimOrNull(path),
    interval: isFile ? null : _intOrNull(interval),
    behavior: isRule ? behavior : null,
    format: isRule ? format : null,
  );
  if (isRule) return next;
  final hc = Map<String, dynamic>.of(base.healthCheck ?? const {})
    ..['enable'] = healthEnabled;
  _putTrimmed(hc, 'url', healthUrl);
  _putInt(hc, 'interval', healthInterval);
  return next.copyWith(healthCheck: hc);
}

String? _trimOrNull(String v) => v.trim().isEmpty ? null : v.trim();

int? _intOrNull(String v) => v.trim().isEmpty ? null : int.tryParse(v.trim());

void _putTrimmed(Map<String, dynamic> m, String k, String v) =>
    v.trim().isEmpty ? m.remove(k) : m[k] = v.trim();

void _putInt(Map<String, dynamic> m, String k, String v) {
  final n = int.tryParse(v.trim());
  n == null ? m.remove(k) : m[k] = n;
}

/// Lists and edits a profile's `proxy-providers:` and `rule-providers:`. Each
/// provider's unknown keys are preserved on write (see [ProviderSpec]). Live
/// traffic/expiry is shown read-only for the active profile's subscriptions.
class ProfileProvidersView extends ConsumerStatefulWidget {
  final int profileId;

  const ProfileProvidersView({super.key, required this.profileId});

  @override
  ConsumerState<ProfileProvidersView> createState() =>
      _ProfileProvidersViewState();
}

class _ProfileProvidersViewState extends ConsumerState<ProfileProvidersView> {
  Map<String, ProviderSpec> _proxy = const {};
  Map<String, ProviderSpec> _rule = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final proxy = await appController.readProxyProviders(widget.profileId);
    final rule = await appController.readRuleProviders(widget.profileId);
    if (!mounted) return;
    setState(() {
      _proxy = proxy;
      _rule = rule;
      _loading = false;
    });
  }

  Future<void> _apply(ProviderKind kind, Map<String, ProviderSpec> next) async {
    final error = kind == ProviderKind.proxy
        ? await appController.writeProxyProviders(widget.profileId, next)
        : await appController.writeRuleProviders(widget.profileId, next);
    if (!mounted) return;
    if (error != null) {
      context.showNotifier(error);
      return;
    }
    setState(() => kind == ProviderKind.proxy ? _proxy = next : _rule = next);
  }

  Map<String, ProviderSpec> _mapOf(ProviderKind kind) =>
      kind == ProviderKind.proxy ? _proxy : _rule;

  Future<void> _edit(ProviderKind kind, String name) async {
    final map = _mapOf(kind);
    final result = await _openEditor(kind, name, map[name]!);
    if (result == null || !mounted) return;
    if (result.name != name && map.containsKey(result.name)) {
      context.showNotifier(appLocalizations.providerNameExists);
      return;
    }
    final next = <String, ProviderSpec>{};
    for (final e in map.entries) {
      next[e.key == name ? result.name : e.key] = e.key == name
          ? result.spec
          : e.value;
    }
    await _apply(kind, next);
  }

  Future<void> _create(ProviderKind kind) async {
    final result = await _openEditor(
      kind,
      '',
      ProviderSpec.create(type: 'http'),
    );
    if (result == null || !mounted) return;
    if (result.name.isEmpty || _mapOf(kind).containsKey(result.name)) {
      context.showNotifier(appLocalizations.providerNameExists);
      return;
    }
    await _apply(kind, {..._mapOf(kind), result.name: result.spec});
  }

  Future<void> _delete(ProviderKind kind, String name) async {
    final ok = await globalState.showMessage(
      title: name,
      message: TextSpan(text: appLocalizations.providerDeleteConfirm),
      confirmText: appLocalizations.delete,
    );
    if (ok != true || !mounted) return;
    await _apply(kind, {..._mapOf(kind)}..remove(name));
  }

  Future<({String name, ProviderSpec spec})?> _openEditor(
    ProviderKind kind,
    String name,
    ProviderSpec spec,
  ) {
    return showExtend<({String name, ProviderSpec spec})>(
      context,
      builder: (_, type) => ProviderEditor(
        type: type,
        kind: kind,
        initialName: name,
        initial: spec,
      ),
    );
  }

  Iterable<Widget> _rows(ProviderKind kind, List<ExternalProvider> runtime) {
    final map = _mapOf(kind);
    return [
      for (final e in map.entries)
        _ProviderRow(
          name: e.key,
          spec: e.value,
          runtime: runtime
              .where((p) => p.name == e.key && p.subscriptionInfo != null)
              .firstOrNull,
          onTap: () => _edit(kind, e.key),
          onDelete: () => _delete(kind, e.key),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final runtime = ref.watch(providersProvider);
    return CommonScaffold(
      title: appLocalizations.providers,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                ...generateSection(
                  title: appLocalizations.proxyProviders,
                  isFirst: true,
                  items: _rows(ProviderKind.proxy, runtime),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _create(ProviderKind.proxy),
                    ),
                  ],
                ),
                ...generateSection(
                  title: appLocalizations.ruleProviders,
                  items: _rows(ProviderKind.rule, runtime),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _create(ProviderKind.rule),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  final String name;
  final ProviderSpec spec;
  final ExternalProvider? runtime;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProviderRow({
    required this.name,
    required this.spec,
    required this.runtime,
    required this.onTap,
    required this.onDelete,
  });

  String _subtitle() {
    final parts = <String>[];
    final behavior = spec.behavior;
    if (behavior != null) parts.add(behavior);
    final interval = spec.interval;
    if (interval != null) {
      parts.add(appLocalizations.providerEveryN(interval));
    }
    final count = runtime?.count ?? 0;
    if (count > 0) parts.add('$count${appLocalizations.entries}');
    return parts.join('  ·  ');
  }

  @override
  Widget build(BuildContext context) {
    final info = runtime?.subscriptionInfo;
    final isSub = spec.type == 'http';
    return ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(isSub ? Icons.cloud_outlined : Icons.description_outlined),
      title: Row(
        children: [
          Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          CommonChip(
            type: ChipType.tonal,
            tonalColor: isSub
                ? context.colorScheme.secondary
                : context.colorScheme.onSurfaceVariant,
            label: isSub
                ? appLocalizations.providerSourceHttp
                : spec.type == 'file'
                ? appLocalizations.providerSourceFile
                : appLocalizations.providerSourceInline,
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(_subtitle(), style: context.textTheme.bodySmall?.toLight),
          if (info != null && info.total != 0) ...[
            const SizedBox(height: 8),
            SubscriptionInfoView(subscriptionInfo: info),
          ],
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}

class ProviderEditor extends StatefulWidget {
  final SheetType type;
  final ProviderKind kind;
  final String initialName;
  final ProviderSpec initial;

  const ProviderEditor({
    super.key,
    required this.type,
    required this.kind,
    required this.initialName,
    required this.initial,
  });

  @override
  State<ProviderEditor> createState() => _ProviderEditorState();
}

class _ProviderEditorState extends State<ProviderEditor> {
  late final TextEditingController _name;
  late final TextEditingController _url;
  late final TextEditingController _path;
  late final TextEditingController _interval;
  late final TextEditingController _healthUrl;
  late final TextEditingController _healthInterval;
  late String _type;
  String? _behavior;
  String? _format;
  late bool _healthEnabled;
  bool _urlVisible = false;

  bool get _isRule => widget.kind == ProviderKind.rule;

  @override
  void initState() {
    super.initState();
    final spec = widget.initial;
    _name = TextEditingController(text: widget.initialName);
    _type = const {'http', 'file', 'inline'}.contains(spec.type)
        ? spec.type
        : 'http';
    _url = TextEditingController(text: spec.url ?? '');
    _path = TextEditingController(text: spec.path ?? '');
    _interval = TextEditingController(text: spec.interval?.toString() ?? '');
    _behavior = spec.behavior;
    _format = spec.format;
    final hc = spec.healthCheck;
    _healthEnabled = hc?['enable'] == true;
    _healthUrl = TextEditingController(text: hc?['url']?.toString() ?? '');
    _healthInterval = TextEditingController(
      text: hc?['interval']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _path.dispose();
    _interval.dispose();
    _healthUrl.dispose();
    _healthInterval.dispose();
    super.dispose();
  }

  ({String name, ProviderSpec spec}) _build() => (
    name: _name.text.trim(),
    spec: buildProviderSpec(
      base: widget.initial,
      isRule: _isRule,
      type: _type,
      url: _url.text,
      path: _path.text,
      interval: _interval.text,
      behavior: _behavior,
      format: _format,
      healthEnabled: _healthEnabled,
      healthUrl: _healthUrl.text,
      healthInterval: _healthInterval.text,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isHttp = _type == 'http';
    final isFile = _type == 'file';
    final extras = widget.initial.extraKeys;
    return AdaptiveSheetScaffold(
      type: widget.type,
      title: _name.text.isEmpty ? appLocalizations.providerNew : _name.text,
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () => Navigator.of(context).pop(_build()),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CommonTextField(
            controller: _name,
            labelText: appLocalizations.name,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          ListHeader(
            title: appLocalizations.providerSource,
            padding: const EdgeInsets.only(bottom: 10),
          ),
          _SourceSegment(
            kind: widget.kind,
            value: _type,
            onChanged: (v) => setState(() => _type = v),
          ),
          if (isHttp) ...[
            const SizedBox(height: 16),
            _UrlField(
              controller: _url,
              visible: _urlVisible,
              onToggle: () => setState(() => _urlVisible = !_urlVisible),
            ),
          ] else ...[
            const SizedBox(height: 16),
            CommonTextField(
              controller: _path,
              labelText: appLocalizations.providerPath,
            ),
          ],
          if (!isFile) ...[
            const SizedBox(height: 16),
            CommonTextField(
              controller: _interval,
              keyboardType: TextInputType.number,
              labelText: appLocalizations.groupHealthInterval,
            ),
          ],
          if (_isRule) ...[
            const SizedBox(height: 20),
            ListHeader(
              title: appLocalizations.providerBehavior,
              padding: const EdgeInsets.only(bottom: 10),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, opt) in _behaviors.indexed)
                  CommonChip(
                    type: ChipType.tonal,
                    tonalColor: _behavior == opt
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    label: [
                      appLocalizations.behaviorDomain,
                      appLocalizations.behaviorIpcidr,
                      appLocalizations.behaviorClassical,
                    ][i],
                    onPressed: () => setState(
                      () => _behavior = _behavior == opt ? null : opt,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ListHeader(
              title: appLocalizations.providerFormat,
              padding: const EdgeInsets.only(bottom: 10),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final opt in _formats)
                  CommonChip(
                    type: ChipType.tonal,
                    tonalColor: _format == opt
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    label: opt,
                    onPressed: () =>
                        setState(() => _format = _format == opt ? null : opt),
                  ),
              ],
            ),
          ],
          if (!_isRule) ...[
            const SizedBox(height: 20),
            ListHeader(
              title: appLocalizations.providerHealthCheck,
              padding: const EdgeInsets.only(bottom: 10),
            ),
            ListItem.switchItem(
              title: Text(appLocalizations.providerHealthCheckEnable),
              delegate: SwitchDelegate<bool>(
                value: _healthEnabled,
                onChanged: (v) => setState(() => _healthEnabled = v),
              ),
            ),
            if (_healthEnabled) ...[
              const SizedBox(height: 8),
              CommonTextField(
                controller: _healthUrl,
                keyboardType: TextInputType.url,
                labelText: appLocalizations.groupHealthUrl,
              ),
              const SizedBox(height: 16),
              CommonTextField(
                controller: _healthInterval,
                keyboardType: TextInputType.number,
                labelText: appLocalizations.groupHealthInterval,
              ),
            ],
          ],
          if (extras.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              appLocalizations.groupExtraKeys(extras.join(', ')),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceSegment extends StatelessWidget {
  final ProviderKind kind;
  final String value;
  final ValueChanged<String> onChanged;

  const _SourceSegment({
    required this.kind,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = <(String, IconData, String)>[
      (
        'http',
        Icons.cloud_download_outlined,
        appLocalizations.providerSourceHttp,
      ),
      ('file', Icons.description_outlined, appLocalizations.providerSourceFile),
      if (kind == ProviderKind.rule)
        (
          'inline',
          Icons.edit_note_outlined,
          appLocalizations.providerSourceInline,
        ),
    ];
    return Row(
      children: [
        for (final (i, opt) in options.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: CommonCard(
              type: CommonCardType.filled,
              isSelected: value == opt.$1,
              onPressed: () => onChanged(opt.$1),
              radius: 13,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Column(
                  children: [
                    Icon(opt.$2, size: 20),
                    const SizedBox(height: 6),
                    Text(opt.$3, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _UrlField extends StatelessWidget {
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggle;

  const _UrlField({
    required this.controller,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final masked = maskProviderUrl(controller.text);
    final hasMask = masked != controller.text;
    if (visible || !hasMask) {
      return CommonTextField(
        controller: controller,
        keyboardType: TextInputType.url,
        labelText: appLocalizations.providerSubscriptionUrl,
        suffixIcon: hasMask
            ? IconButton(
                icon: const Icon(Icons.visibility_off_outlined),
                onPressed: onToggle,
              )
            : null,
      );
    }
    return InputDecorator(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: appLocalizations.providerSubscriptionUrl,
        suffixIcon: IconButton(
          icon: const Icon(Icons.visibility_outlined),
          onPressed: onToggle,
        ),
      ),
      child: Text(masked, style: context.textTheme.bodyMedium),
    );
  }
}
