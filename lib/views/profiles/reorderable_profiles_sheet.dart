import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ReorderableProfilesSheet extends StatefulWidget {
  final List<Profile> profiles;
  final SheetType type;

  const ReorderableProfilesSheet({
    super.key,
    required this.profiles,
    required this.type,
  });

  @override
  State<ReorderableProfilesSheet> createState() =>
      _ReorderableProfilesSheetState();
}

class _ReorderableProfilesSheetState extends State<ReorderableProfilesSheet> {
  late List<Profile> profiles;

  @override
  void initState() {
    super.initState();
    profiles = List.from(widget.profiles);
  }

  Widget _buildItem(int index, [bool isDecorator = false]) {
    final isLast = index == profiles.length - 1;
    final isFirst = index == 0;
    final profile = profiles[index];
    return CommonInputListItem(
      key: Key(profile.id.toString()),
      trailing: ReorderableDelayedDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      ),
      title: Text(profile.realLabel),
      isFirst: isFirst,
      isLast: isLast,
      isDecorator: isDecorator,
    );
  }

  void _handleSave() {
    Navigator.of(context).pop();
    appController.reorder(profiles);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      type: widget.type,
      actions: [
        if (widget.type == SheetType.bottomSheet)
          IconButton.filledTonal(
            onPressed: _handleSave,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.comfortable,
              tapTargetSize: MaterialTapTargetSize.padded,
              padding: const EdgeInsets.all(8),
              iconSize: 20,
            ),
            icon: const Icon(Icons.check),
          )
        else
          IconButton.filledTonal(
            icon: const Icon(Icons.check),
            onPressed: _handleSave,
          ),
      ],
      body: Padding(
        padding: const EdgeInsets.only(bottom: 32, top: 12),
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          proxyDecorator: (child, index, animation) {
            return commonProxyDecorator(
              _buildItem(index, true),
              index,
              animation,
            );
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final profile = profiles.removeAt(oldIndex);
              profiles.insert(newIndex, profile);
            });
          },
          itemBuilder: (_, index) {
            return _buildItem(index);
          },
          itemCount: profiles.length,
        ),
      ),
      title: appLocalizations.profilesSort,
    );
  }
}
