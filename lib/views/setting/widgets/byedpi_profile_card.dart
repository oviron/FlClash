import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

class ByeDpiProfileCard extends StatelessWidget {
  final BypassProfile profile;
  final int dragIndex;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleEnabled;

  const ByeDpiProfileCard({
    super.key,
    required this.profile,
    required this.dragIndex,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      key: ValueKey('byedpi-card-${profile.id}'),
      opacity: profile.enabled ? 1.0 : 0.5,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: dragIndex,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.drag_handle),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.isEmpty
                          ? appLocalizations.byedpiNewProfile
                          : profile.name,
                      style: context.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.domains.length} domains · '
                      '${profile.apps.length} apps',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_ProfileMenu>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case _ProfileMenu.edit:
                      onEdit();
                    case _ProfileMenu.toggle:
                      onToggleEnabled();
                    case _ProfileMenu.delete:
                      onDelete();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _ProfileMenu.edit,
                    child: Text(appLocalizations.networkRulesEdit),
                  ),
                  PopupMenuItem(
                    value: _ProfileMenu.toggle,
                    child: Text(
                      profile.enabled
                          ? appLocalizations.networkRulesDisable
                          : appLocalizations.networkRulesEnableShort,
                    ),
                  ),
                  PopupMenuItem(
                    value: _ProfileMenu.delete,
                    child: Text(appLocalizations.byedpiDelete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ProfileMenu { edit, toggle, delete }
