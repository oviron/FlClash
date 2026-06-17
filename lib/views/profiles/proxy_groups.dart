import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/profile_routing/group_spec.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _types = ['select', 'url-test', 'fallback', 'load-balance', 'relay'];
const _builtins = ['DIRECT', 'REJECT', 'GLOBAL'];

bool _isHealthType(String type) =>
    type == 'url-test' || type == 'fallback' || type == 'load-balance';

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
    final ok = await _confirm(_groups[index].name);
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
    return BaseNavigator.push<GroupSpec>(
      context,
      _GroupEditorView(initial: group, candidates: candidates),
    );
  }

  Future<bool?> _confirm(String name) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(name),
      content: Text(appLocalizations.groupDeleteConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(appLocalizations.delete),
        ),
      ],
    ),
  );

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

  const _GroupEditorView({required this.initial, required this.candidates});

  @override
  State<_GroupEditorView> createState() => _GroupEditorViewState();
}

class _GroupEditorViewState extends State<_GroupEditorView> {
  late final TextEditingController _name;
  late final TextEditingController _url;
  late final TextEditingController _interval;
  late String _type;
  late List<String> _members;
  late bool _lazy;

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
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _interval.dispose();
    super.dispose();
  }

  GroupSpec _build() {
    final base = widget.initial.copyWith(
      name: _name.text.trim(),
      type: _type,
      proxies: _members,
    );
    if (!_isHealthType(_type)) return base;
    return base.copyWith(
      url: _url.text.trim().isEmpty ? null : _url.text.trim(),
      interval: _interval.text.trim().isEmpty
          ? null
          : int.tryParse(_interval.text.trim()),
      lazy: _lazy,
    );
  }

  Future<void> _addMember() async {
    final pool = widget.candidates.where((c) => !_members.contains(c)).toList();
    if (pool.isEmpty) return;
    final picked = await showSheet<String>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) => AdaptiveSheetScaffold(
        type: type,
        title: appLocalizations.groupAddMember,
        body: ListView(
          shrinkWrap: true,
          children: [
            for (final c in pool)
              ListTile(
                title: Text(c),
                onTap: () => Navigator.of(context).pop(c),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _members = [..._members, picked]);
  }

  @override
  Widget build(BuildContext context) {
    final health = _isHealthType(_type);
    final extras = widget.initial.extraKeys;
    return CommonScaffold(
      title: _name.text.isEmpty ? appLocalizations.groupNew : _name.text,
      actions: [
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
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: appLocalizations.groupType,
            ),
            items: [
              for (final t in _types)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => setState(() => _type = v ?? _type),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () =>
                          setState(() => _members = [..._members]..remove(m)),
                    ),
                  ),
              ],
            ),
          if (extras.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              appLocalizations.groupExtraKeys(extras.join(', ')),
              style: context.textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
