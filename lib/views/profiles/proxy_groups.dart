import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/profile_routing/group_spec.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaml/yaml.dart';

const _types = ['select', 'url-test', 'fallback', 'load-balance', 'relay'];
const _builtins = ['DIRECT', 'REJECT', 'GLOBAL'];

const _typeIcons = {
  'select': Icons.touch_app_outlined,
  'url-test': Icons.bolt_outlined,
  'fallback': Icons.shield_outlined,
  'load-balance': Icons.balance_outlined,
  'relay': Icons.link_outlined,
};

const _filterKey = 'filter';

bool _isHealthType(String type) =>
    type == 'url-test' || type == 'fallback' || type == 'load-balance';

/// Pure group-editor reducer: applies the edited fields onto [base], preserving
/// every unmodeled key. Health fields apply only to health-check types; `filter`
/// is set/cleared by [filterMode]; [extras] carry edited unknown key/values.
GroupSpec buildGroupSpec({
  required GroupSpec base,
  required String name,
  required String type,
  required List<String> members,
  required bool filterMode,
  required String filter,
  required Map<String, String> extras,
  String url = '',
  String interval = '',
  bool lazy = false,
}) {
  var spec = base.copyWith(name: name.trim(), type: type, proxies: members);
  if (_isHealthType(type)) {
    spec = spec.copyWith(
      url: url.trim().isEmpty ? null : url.trim(),
      interval: interval.trim().isEmpty ? null : int.tryParse(interval.trim()),
      lazy: lazy,
    );
  }
  spec = _withExtraKey(
    spec,
    _filterKey,
    filterMode && filter.trim().isNotEmpty ? filter.trim() : null,
  );
  for (final e in extras.entries) {
    final original = base.raw[e.key];
    // Untouched keys keep their original typed value; edited ones re-infer
    // their YAML type, so a bool/int/list is never coerced to a string.
    final value = original != null && original.toString() == e.value
        ? original
        : _inferYaml(e.value);
    spec = _withExtraKey(spec, e.key, value);
  }
  return spec;
}

/// Set/remove one unmodeled key on a [GroupSpec], preserving the rest. Kept here
/// (not on GroupSpec) so the lossless codec type stays untouched.
GroupSpec _withExtraKey(GroupSpec g, String key, Object? value) {
  final m = Map<String, dynamic>.of(g.raw);
  value == null ? m.remove(key) : m[key] = value;
  return GroupSpec(m);
}

/// Parses an edited extra-key string back to its YAML type (bool/int/list/map),
/// so `true`/`5`/`[a, b]` are not written as quoted strings. Falls back to the
/// raw string when it is not valid YAML.
Object? _inferYaml(String value) {
  try {
    return yamlToDart(loadYaml(value));
  } on YamlException {
    return value;
  }
}

/// Lists and edits a profile's `proxy-groups:`. Each group's unknown keys
/// (strategy, filter, ...) are preserved on write; see [GroupSpec].
class ProxyGroupsView extends ConsumerStatefulWidget {
  final int profileId;

  const ProxyGroupsView({super.key, required this.profileId});

  @override
  ConsumerState<ProxyGroupsView> createState() => _ProxyGroupsViewState();
}

class _ProxyGroupsViewState extends ConsumerState<ProxyGroupsView> {
  List<GroupSpec> _groups = const [];
  List<String> _candidates = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groups = await appController.readProxyGroups(widget.profileId);
    final candidates = await appController.readGroupMemberCandidates(
      widget.profileId,
    );
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _candidates = candidates;
      _loading = false;
    });
  }

  Future<void> _apply(List<GroupSpec> next) async {
    final error = await appController.writeProxyGroups(widget.profileId, next);
    if (!mounted) return;
    if (error != null) {
      context.showNotifier(error);
    } else {
      setState(() => _groups = next);
    }
  }

  bool _nameTaken(String name, {String? except}) =>
      _groups.any((g) => g.name == name && g.name != except);

  Future<void> _create() async {
    final result = await _openEditor(
      GroupSpec.create(name: '', type: 'select'),
    );
    if (result == null || !mounted) return;
    if (result.name.isEmpty || _nameTaken(result.name)) {
      context.showNotifier(appLocalizations.groupNameExists);
      return;
    }
    await _apply([..._groups, result]);
  }

  Future<void> _edit(int index) async {
    final result = await _openEditor(_groups[index]);
    if (result == null || !mounted) return;
    if (result.name.isEmpty ||
        _nameTaken(result.name, except: _groups[index].name)) {
      context.showNotifier(appLocalizations.groupNameExists);
      return;
    }
    final next = [..._groups];
    next[index] = result;
    await _apply(next);
  }

  Future<void> _delete(int index) async {
    final ok = await globalState.showMessage(
      title: _groups[index].name,
      message: TextSpan(text: appLocalizations.groupDeleteConfirm),
      confirmText: appLocalizations.delete,
    );
    if (ok != true || !mounted) return;
    await _apply([..._groups]..removeAt(index));
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final next = [..._groups];
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    next.insert(adjusted, next.removeAt(oldIndex));
    await _apply(next);
  }

  Future<GroupSpec?> _openEditor(GroupSpec group) {
    final candidates = [
      ..._builtins,
      ..._candidates.where((c) => c != group.name),
    ];
    final delays = {
      for (final c in candidates) c: ref.read(getDelayProvider(proxyName: c)),
    };
    return BaseNavigator.push<GroupSpec>(
      context,
      _GroupEditorView(initial: group, candidates: candidates, delays: delays),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: appLocalizations.proxyGroups,
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
          ? NullStatus(label: appLocalizations.nullTip(appLocalizations.group))
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: _groups.length,
              onReorder: _reorder,
              itemBuilder: (_, index) {
                final g = _groups[index];
                return ListTile(
                  key: ValueKey('${g.name}#$index'),
                  leading: const Icon(Icons.lan_outlined),
                  title: Text(g.name),
                  subtitle: Text(
                    '${g.type} · ${appLocalizations.groupMemberCount(g.proxies.length)}',
                  ),
                  onTap: () => _edit(index),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(index),
                  ),
                );
              },
            ),
    );
  }
}

class _GroupEditorView extends StatefulWidget {
  final GroupSpec initial;
  final List<String> candidates;
  final Map<String, int?> delays;

  const _GroupEditorView({
    required this.initial,
    required this.candidates,
    required this.delays,
  });

  @override
  State<_GroupEditorView> createState() => _GroupEditorViewState();
}

class _GroupEditorViewState extends State<_GroupEditorView> {
  late final TextEditingController _name;
  late final TextEditingController _url;
  late final TextEditingController _interval;
  late final TextEditingController _filter;
  late String _type;
  late List<String> _members;
  late bool _lazy;
  late Map<String, String> _extras; // unmodeled keys minus `filter`
  late bool _filterMode;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial.name);
    _type = _types.contains(widget.initial.type)
        ? widget.initial.type
        : 'select';
    _members = [...widget.initial.proxies];
    _url = TextEditingController(text: widget.initial.url ?? '');
    _interval = TextEditingController(
      text: widget.initial.interval?.toString() ?? '',
    );
    _lazy = widget.initial.lazy;
    final raw = widget.initial.raw;
    _filterMode = raw.containsKey(_filterKey);
    _filter = TextEditingController(text: raw[_filterKey]?.toString() ?? '');
    _extras = {
      for (final k in widget.initial.extraKeys)
        if (k != _filterKey) k: raw[k]?.toString() ?? '',
    };
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _interval.dispose();
    _filter.dispose();
    super.dispose();
  }

  GroupSpec _build() => buildGroupSpec(
    base: widget.initial,
    name: _name.text,
    type: _type,
    members: _members,
    filterMode: _filterMode,
    filter: _filter.text,
    extras: _extras,
    url: _url.text,
    interval: _interval.text,
    lazy: _lazy,
  );

  Future<void> _addMember() async {
    final pool = widget.candidates.where((c) => !_members.contains(c)).toList();
    if (pool.isEmpty) return;
    final picked = await showSheet<List<String>>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) =>
          _MemberPickerSheet(type: type, pool: pool, delays: widget.delays),
    );
    if (picked != null && picked.isNotEmpty) {
      setState(() => _members = [..._members, ...picked]);
    }
  }

  Future<void> _addExtraKey() async {
    final key = await _promptKey();
    if (key == null || key.isEmpty || !mounted) return;
    if (key == _filterKey || _extras.containsKey(key)) return;
    setState(() => _extras = {..._extras, key: ''});
  }

  Future<String?> _promptKey() async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(appLocalizations.groupAddKey),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: appLocalizations.key,
            ),
            onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appLocalizations.cancel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(appLocalizations.confirm),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  void _showYaml() {
    final text = yaml.encode(_build().raw);
    showSheet<void>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) => AdaptiveSheetScaffold(
        type: type,
        title: appLocalizations.groupOpenYaml,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            text,
            style: context.textTheme.bodyMedium?.toJetBrainsMono,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final health = _isHealthType(_type);
    return CommonScaffold(
      title: _name.text.isEmpty ? appLocalizations.groupNew : _name.text,
      actions: [
        IconButton(
          tooltip: appLocalizations.groupOpenYaml,
          icon: const Icon(Icons.code),
          onPressed: _showYaml,
        ),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () => Navigator.of(context).pop(_build()),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: appLocalizations.name,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text(appLocalizations.groupType, style: context.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _types)
                ChoiceChip(
                  avatar: Icon(_typeIcons[t], size: 18),
                  label: Text(t),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          if (health) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.groupHealthUrl,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _interval,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.groupHealthInterval,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(appLocalizations.groupLazy),
              value: _lazy,
              onChanged: (v) => setState(() => _lazy = v),
            ),
          ],
          const SizedBox(height: 16),
          _filterSection(context),
          const SizedBox(height: 8),
          _extrasSection(context),
        ],
      ),
    );
  }

  Widget _filterSection(BuildContext context) {
    if (_filterMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.groupFilterMembers,
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _filter,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: appLocalizations.groupFilterRegex,
              helperText: appLocalizations.groupFilterHint,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _filterMode = false),
              icon: const Icon(Icons.list),
              label: Text(appLocalizations.groupMembersManual),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Row(
          children: [
            Text(
              appLocalizations.groupMembers,
              style: context.textTheme.titleSmall,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addMember,
              icon: const Icon(Icons.add),
              label: Text(appLocalizations.groupAddMember),
            ),
          ],
        ),
        if (_members.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              appLocalizations.nullTip(appLocalizations.groupMembers),
              style: context.textTheme.bodySmall,
            ),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) => setState(() {
              final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
              _members.insert(adjusted, _members.removeAt(oldIndex));
            }),
            children: [
              for (final m in _members)
                ListTile(
                  key: ValueKey(m),
                  dense: true,
                  title: Text(m),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LatencyBadge(widget.delays[m]),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () =>
                            setState(() => _members = [..._members]..remove(m)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _extrasSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              appLocalizations.groupAdvancedKeys,
              style: context.textTheme.titleSmall,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addExtraKey,
              icon: const Icon(Icons.add),
              label: Text(appLocalizations.groupAddKey),
            ),
          ],
        ),
        for (final key in _extras.keys.toList())
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _extras[key],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: key,
                    ),
                    onChanged: (v) => _extras[key] = v,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () =>
                      setState(() => _extras = {..._extras}..remove(key)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MemberPickerSheet extends StatefulWidget {
  final SheetType type;
  final List<String> pool;
  final Map<String, int?> delays;

  const _MemberPickerSheet({
    required this.type,
    required this.pool,
    required this.delays,
  });

  @override
  State<_MemberPickerSheet> createState() => _MemberPickerSheetState();
}

class _MemberPickerSheetState extends State<_MemberPickerSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      type: widget.type,
      title: appLocalizations.groupAddMember,
      actions: [
        TextButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selected.toList()),
          child: Text(appLocalizations.confirm),
        ),
      ],
      body: ListView(
        shrinkWrap: true,
        children: [
          for (final c in widget.pool)
            CheckboxListTile(
              dense: true,
              value: _selected.contains(c),
              title: Text(c),
              secondary: LatencyBadge(widget.delays[c]),
              onChanged: (v) => setState(() {
                v == true ? _selected.add(c) : _selected.remove(c);
              }),
            ),
        ],
      ),
    );
  }
}
