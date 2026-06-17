import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

import 'effect.dart';
import 'pop_scope.dart';
import 'scaffold.dart';

/// Optional per-row badge for list mode (e.g. "DoH" next to a DNS URL).
typedef ListRowTagBuilder = String? Function(String value);

/// A pure, reusable list / map editor driven by [value] + [onChanged].
///
/// No provider coupling: the host owns persistence and passes the current
/// value down, receiving the edited copy back through [onChanged]. Used for
/// DNS nameserver lists, fake-ip filters, nameserver-policy, hosts, etc.
class ListMapEditor extends StatefulWidget {
  /// List mode: reorderable string rows with add / remove and an optional tag.
  const ListMapEditor.list({
    super.key,
    required List<String> value,
    required ValueChanged<List<String>> onChanged,
    this.addLabel,
    this.valueLabel,
    this.tagBuilder,
  }) : _list = value,
       _onListChanged = onChanged,
       _map = null,
       _onMapChanged = null,
       keyLabel = null;

  /// Map mode: key -> list of value chips, each card with add / remove.
  const ListMapEditor.map({
    super.key,
    required Map<String, List<String>> value,
    required ValueChanged<Map<String, List<String>>> onChanged,
    this.addLabel,
    this.keyLabel,
    this.valueLabel,
  }) : _map = value,
       _onMapChanged = onChanged,
       _list = null,
       _onListChanged = null,
       tagBuilder = null;

  final List<String>? _list;
  final ValueChanged<List<String>>? _onListChanged;
  final Map<String, List<String>>? _map;
  final ValueChanged<Map<String, List<String>>>? _onMapChanged;

  final String? addLabel;
  final String? keyLabel;
  final String? valueLabel;
  final ListRowTagBuilder? tagBuilder;

  bool get isMap => _map != null;

  @override
  State<ListMapEditor> createState() => _ListMapEditorState();
}

class _ListMapEditorState extends State<ListMapEditor> {
  late List<String> _list;
  late List<MapEntry<String, List<String>>> _map;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(ListMapEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    _list = List<String>.from(widget._list ?? const []);
    _map = [
      for (final e in (widget._map ?? const <String, List<String>>{}).entries)
        MapEntry(e.key, List<String>.from(e.value)),
    ];
  }

  void _emitList() => widget._onListChanged?.call(List<String>.from(_list));

  void _emitMap() => widget._onMapChanged?.call({
    for (final e in _map) e.key: List<String>.from(e.value),
  });

  Future<String?> _prompt({String? initial}) {
    return showDialog<String>(
      context: context,
      builder: (_) => _SingleFieldDialog(
        label: widget.valueLabel ?? appLocalizations.value,
        initial: initial,
      ),
    );
  }

  Future<String?> _promptKey({String? initial}) {
    return showDialog<String>(
      context: context,
      builder: (_) => _SingleFieldDialog(
        label: widget.keyLabel ?? appLocalizations.key,
        initial: initial,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isMap ? _buildMap(context) : _buildList(context);
  }

  // ---- list mode ----------------------------------------------------------

  Future<void> _addRow() async {
    final value = await _prompt();
    if (value == null || value.isEmpty) return;
    setState(() => _list.add(value));
    _emitList();
  }

  Future<void> _editRow(int index) async {
    final value = await _prompt(initial: _list[index]);
    if (value == null || value.isEmpty) return;
    setState(() => _list[index] = value);
    _emitList();
  }

  void _removeRow(int index) {
    setState(() => _list.removeAt(index));
    _emitList();
  }

  void _reorderRow(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    setState(() => _list.insert(newIndex, _list.removeAt(oldIndex)));
    _emitList();
  }

  Widget _buildList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _list.length,
          onReorder: _reorderRow,
          proxyDecorator: (child, index, animation) =>
              commonProxyDecorator(child, index, animation),
          itemBuilder: (_, index) => _ListRow(
            key: ValueKey('lme-row-$index-${_list[index]}'),
            index: index,
            value: _list[index],
            tag: widget.tagBuilder?.call(_list[index]),
            onTap: () => _editRow(index),
            onRemove: () => _removeRow(index),
          ),
        ),
        const SizedBox(height: 4),
        _AddButton(
          label: widget.addLabel ?? appLocalizations.add,
          onPressed: _addRow,
        ),
      ],
    );
  }

  // ---- map mode -----------------------------------------------------------

  Future<void> _addEntry() async {
    final key = await _promptKey();
    if (key == null || key.isEmpty) return;
    if (_map.any((e) => e.key == key)) return;
    setState(() => _map.add(MapEntry(key, <String>[])));
    _emitMap();
  }

  void _removeEntry(int index) {
    setState(() => _map.removeAt(index));
    _emitMap();
  }

  Future<void> _addValue(int index) async {
    final value = await _prompt();
    if (value == null || value.isEmpty) return;
    setState(() => _map[index].value.add(value));
    _emitMap();
  }

  void _removeValue(int entryIndex, int valueIndex) {
    setState(() => _map[entryIndex].value.removeAt(valueIndex));
    _emitMap();
  }

  Widget _buildMap(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _map.length; i++)
          _MapCard(
            key: ValueKey('lme-card-${_map[i].key}'),
            entryKey: _map[i].key,
            values: _map[i].value,
            onAddValue: () => _addValue(i),
            onRemoveValue: (vi) => _removeValue(i, vi),
            onRemoveEntry: () => _removeEntry(i),
          ),
        const SizedBox(height: 4),
        _AddButton(
          label: widget.addLabel ?? appLocalizations.add,
          onPressed: _addEntry,
        ),
      ],
    );
  }
}

class _ListRow extends StatelessWidget {
  final int index;
  final String value;
  final String? tag;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _ListRow({
    super.key,
    required this.index,
    required this.value,
    required this.tag,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_indicator,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ),
                if (tag != null && tag!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _Tag(tag!),
                ],
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: onRemove,
                  icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: ShapeDecoration(
        color: scheme.tertiaryContainer,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: scheme.onTertiaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final String entryKey;
  final List<String> values;
  final VoidCallback onAddValue;
  final ValueChanged<int> onRemoveValue;
  final VoidCallback onRemoveEntry;

  const _MapCard({
    super.key,
    required this.entryKey,
    required this.values,
    required this.onAddValue,
    required this.onRemoveValue,
    required this.onRemoveEntry,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLow,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entryKey,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: onRemoveEntry,
                  icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < values.length; i++)
                InputChip(
                  label: Text(
                    values[i],
                    style: const TextStyle(fontFamily: 'JetBrainsMono'),
                  ),
                  onDeleted: () => onRemoveValue(i),
                  visualDensity: VisualDensity.compact,
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: Text(appLocalizations.add),
                visualDensity: VisualDensity.compact,
                onPressed: onAddValue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _AddButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 11),
        side: BorderSide(color: scheme.outline),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _SingleFieldDialog extends StatefulWidget {
  final String label;
  final String? initial;

  const _SingleFieldDialog({required this.label, this.initial});

  @override
  State<_SingleFieldDialog> createState() => _SingleFieldDialogState();
}

class _SingleFieldDialogState extends State<_SingleFieldDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.label),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.label,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(appLocalizations.confirm)),
      ],
    );
  }
}

/// Scaffold host for [ListMapEditor.list]. Returns the edited list via pop, so
/// it slots into the existing `OpenDelegate(onChanged:)` flow like ListInputPage.
class ListEditorPage extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? addLabel;
  final String? valueLabel;
  final ListRowTagBuilder? tagBuilder;

  const ListEditorPage({
    super.key,
    required this.title,
    required this.items,
    this.addLabel,
    this.valueLabel,
    this.tagBuilder,
  });

  @override
  State<ListEditorPage> createState() => _ListEditorPageState();
}

class _ListEditorPageState extends State<ListEditorPage> {
  late List<String> _items = List<String>.from(widget.items);

  @override
  Widget build(BuildContext context) {
    return CommonPopScope(
      onPop: (_) {
        Navigator.of(context).pop(_items);
        return false;
      },
      child: CommonScaffold(
        title: widget.title,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            ListMapEditor.list(
              value: _items,
              addLabel: widget.addLabel,
              valueLabel: widget.valueLabel,
              tagBuilder: widget.tagBuilder,
              onChanged: (next) => _items = next,
            ),
          ],
        ),
      ),
    );
  }
}

/// Scaffold host for [ListMapEditor.map]. Adapts the persisted
/// `Map<String, String>` (mihomo encodes multi-value as comma-separated) to the
/// editor's `Map<String, List<String>>`, joining back on pop.
class MapEditorPage extends StatefulWidget {
  final String title;
  final Map<String, String> map;
  final String? addLabel;
  final String? keyLabel;
  final String? valueLabel;

  const MapEditorPage({
    super.key,
    required this.title,
    required this.map,
    this.addLabel,
    this.keyLabel,
    this.valueLabel,
  });

  static List<String> split(String value) =>
      value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  State<MapEditorPage> createState() => _MapEditorPageState();
}

class _MapEditorPageState extends State<MapEditorPage> {
  late Map<String, List<String>> _map = {
    for (final e in widget.map.entries) e.key: MapEditorPage.split(e.value),
  };

  Map<String, String> get _persisted => {
    for (final e in _map.entries) e.key: e.value.join(','),
  };

  @override
  Widget build(BuildContext context) {
    return CommonPopScope(
      onPop: (_) {
        Navigator.of(context).pop(_persisted);
        return false;
      },
      child: CommonScaffold(
        title: widget.title,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            ListMapEditor.map(
              value: _map,
              addLabel: widget.addLabel,
              keyLabel: widget.keyLabel,
              valueLabel: widget.valueLabel,
              onChanged: (next) => _map = next,
            ),
          ],
        ),
      ),
    );
  }
}
