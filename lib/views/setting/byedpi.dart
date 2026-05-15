import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/byedpi.dart';
import 'package:fl_clash/views/setting/widgets/byedpi_profile_card.dart';
import 'package:fl_clash/views/setting/widgets/edit_byedpi_profile_dialog.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ByeDpiView extends ConsumerWidget {
  const ByeDpiView({super.key});

  Future<void> _openCreateDialog(BuildContext context, WidgetRef ref) async {
    final created = await EditByeDpiProfileDialog.show(context: context);
    if (created == null) return;
    await ref.read(bypassProfilesRepoProvider.notifier).add(created);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(byeDpiSettingsProvider);
    final profilesAsync = ref.watch(bypassProfilesStreamProvider);

    return BaseScaffold(
      title: appLocalizations.byedpiTitle,
      body: Stack(
        children: [
          Column(
            children: [
              _MasterToggleCard(enabled: settings.enabled),
              const Divider(height: 0),
              _CliArgsField(cliArgs: settings.cliArgs),
              const Divider(height: 0),
              Expanded(
                child: profilesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (profiles) => _ProfilesList(
                    profiles: profiles,
                    masterEnabled: settings.enabled,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 80,
            child: FloatingActionButton.extended(
              onPressed: settings.enabled
                  ? () => _openCreateDialog(context, ref)
                  : null,
              icon: const Icon(Icons.add),
              label: Text(appLocalizations.byedpiAddProfile),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterToggleCard extends ConsumerWidget {
  final bool enabled;
  const _MasterToggleCard({required this.enabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwitchListTile(
      secondary: const Icon(Icons.toggle_on_outlined),
      title: Text(appLocalizations.byedpiEnable),
      value: enabled,
      onChanged: (v) {
        ref.read(byeDpiSettingsProvider.notifier).setEnabled(v);
      },
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

class _ProfilesList extends ConsumerWidget {
  final List<BypassProfile> profiles;
  final bool masterEnabled;

  const _ProfilesList({required this.profiles, required this.masterEnabled});

  Future<void> _openEditDialog(
    BuildContext context,
    WidgetRef ref,
    BypassProfile profile,
  ) async {
    final updated = await EditByeDpiProfileDialog.show(
      context: context,
      initial: profile,
    );
    if (updated == null) return;
    await ref.read(bypassProfilesRepoProvider.notifier).update(updated);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BypassProfile profile,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(appLocalizations.byedpiConfirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(appLocalizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(appLocalizations.byedpiDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(bypassProfilesRepoProvider.notifier).delete(profile.id);
  }

  Future<void> _toggleEnabled(WidgetRef ref, BypassProfile profile) async {
    await ref
        .read(bypassProfilesRepoProvider.notifier)
        .update(profile.copyWith(enabled: !profile.enabled));
  }

  Future<void> _onReorder(WidgetRef ref, int oldIndex, int newIndex) async {
    final ids = profiles.map((p) => p.id).toList();
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final moved = ids.removeAt(oldIndex);
    ids.insert(adjusted, moved);
    await ref.read(bypassProfilesRepoProvider.notifier).reorder(ids);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (profiles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            appLocalizations.byedpiProfilesEmpty,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Opacity(
      opacity: masterEnabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !masterEnabled,
        child: ReorderableListView.builder(
          itemCount: profiles.length,
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.only(bottom: 160),
          onReorder: (oldIndex, newIndex) =>
              _onReorder(ref, oldIndex, newIndex),
          itemBuilder: (_, index) {
            final profile = profiles[index];
            return ByeDpiProfileCard(
              key: ValueKey(profile.id),
              profile: profile,
              dragIndex: index,
              onEdit: () => _openEditDialog(context, ref, profile),
              onDelete: () => _confirmDelete(context, ref, profile),
              onToggleEnabled: () => _toggleEnabled(ref, profile),
            );
          },
        ),
      ),
    );
  }
}
